//
//  TrajectoryViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryViewController.h"
#import <MapKit/MapKit.h>
#import "Polyline_points+CoreDataMethods.h"
#import "TrajectoryPlanner.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Annotation.h"
#import "Bus_points+CoreDataMethods.h"

@interface TrajectoryViewController () <MKMapViewDelegate, TreeDataRequestDelegate>

@property (nonatomic) NSOperationQueue* queue;
@property (nonatomic) NSArray* annotations;
@property (nonatomic) NSMutableArray* overlays;
@property (nonatomic) NSMutableArray* colors;

@end

@implementation TrajectoryViewController

@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
	self.mapView.showsUserLocation = YES;
	self.queue = [[NSOperationQueue alloc] init];
	self.overlays = [[NSMutableArray alloc] init];
	self.colors = [[NSMutableArray alloc] init];
}
-(void)viewWillDisappear:(BOOL)animated{
	self.mapView.showsUserLocation = YES;
	[self.mapView removeOverlays:self.overlays];
	[self.overlays removeAllObjects];
	[self.colors removeAllObjects];
}


- (void)addRoute: (NSArray *)route withType: (NSString *)type
{
    CLLocationCoordinate2D *coordinates = [route count] ? malloc(sizeof(CLLocationCoordinate2D)* [route count]) : NULL;
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order"
																 ascending:YES];
	
    route = [route sortedArrayUsingDescriptors:@[descriptor]];
	Polyline_points* point;
	for (NSInteger index = 0; index < [route count]; index++) {
		point = [route objectAtIndex:index];
		coordinates[index] = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
	}

		if (coordinates) {
			MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[route count]];
			[self.overlays addObject:polyLine];
			free(coordinates);
			[self.mapView addOverlay:polyLine];
		}

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
	UIColor * color = [[UIColor alloc] initWithRed:(arc4random() % 255) / 255.0 green:(arc4random() % 255) / 255.0 blue:(arc4random() % 255) / 255.0 alpha:1];
	[self.colors addObject:color];
    polylineView.strokeColor = color;
    polylineView.lineWidth = 5.0;
    return polylineView;
}

- (void)creatAnnotationsFromBusPointsArray:(NSArray*)stopsNear{
	
    NSMutableArray* annotationArray = [[NSMutableArray alloc] init];
	int i = 0;
    //Each annotation has: title, subtitle, coordinate and index
	for (Bus_points* stop in stopsNear){
        Annotation* annotation = [[Annotation alloc] init];
		NSString* subTitle = [[NSString alloc] init];
		for (Bus_line* bus in stop.onibus_que_passam) {
			subTitle = [subTitle stringByAppendingString:[NSString stringWithFormat:@"%@, ", bus.line_number]];
		}
		subTitle = [subTitle substringToIndex:[subTitle length]-2];
        if ([stop.onibus_que_passam count] == 1){
            [annotation setTitle: @"1 linha passa aqui:"];
        } else {
            [annotation setTitle: [NSString stringWithFormat: @"%lu linhas passam aqui:", (unsigned long)[stop.onibus_que_passam count]]];
        }
		[annotation setSubtitle: subTitle];
        [annotation setCoordinate: CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue])];
        [annotationArray addObject: annotation];
		annotation.index = i;
		i++;
    }
	MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
	[annotation setCoordinate:self.final];
	[annotation setTitle:@"Destino!"];
	[annotationArray addObject:annotation];

	[self setAnnotations:annotationArray];
}
//Remove old annotations and set new ones
- (void)updateMapView
{
    if (self.mapView.annotations){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations){
        [self.mapView addAnnotations: self.annotations];
    }
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}


-(void)requestDataDidFinishWithInitialArray:(NSArray *)initial andWithFinal:(NSArray *)final{

		TrajectoryPlanner *trajectory = [[TrajectoryPlanner alloc] init];
		self.bus = [[NSArray alloc] initWithArray:[trajectory planningFrom: initial to: final]];
		if ([self.bus count]) {
			NSMutableArray* busPoints = [[NSMutableArray alloc] init];
			for (Bus_line* line in self.bus) {
				[busPoints addObjectsFromArray:[Bus_points getBusLineStops:line]];
			}
			
				[self creatAnnotationsFromBusPointsArray:busPoints];
				for (Bus_line *line in self.bus){
					[self addRoute:  [line.polyline_ida allObjects] withType: @"ida"];
					[self addRoute: [line.polyline_volta allObjects] withType: @"volta"];
				}
		}
		


}
-(void)requestdidFailWithError:(NSError *)error{
	NSLog(@"Error!");
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	[self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
	MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span);
    
    [self.mapView setRegion: viewRegion animated:YES];
	[[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
	NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
	
	[[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:userLocation.coordinate andFinalPoint:self.final withRange:[prefs integerForKey:@"SearchRadius"]];
}

//Configure annotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"myAnnotation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"ThePin.png"];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    
    return nil;
}

@end
