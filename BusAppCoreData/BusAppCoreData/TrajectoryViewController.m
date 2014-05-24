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
#import "InformationViewController.h"


@interface TrajectoryViewController () <MKMapViewDelegate, TreeDataRequestDelegate>

@property (nonatomic) NSOperationQueue* queue;
@property (nonatomic) NSArray* annotations;
@property (nonatomic) NSMutableArray* overlays;
@property (nonatomic) NSMutableArray* colors;
@property (nonatomic) BOOL gotInfo;
@property (nonatomic) BOOL gotUserLocation;


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
	[self setThingsOnMap:self.initial];
}

-(void)viewWillDisappear:(BOOL)animated{
	self.mapView.showsUserLocation = NO;
}

-(void)viewWillAppear:(BOOL)animated{
	self.mapView.showsUserLocation = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.overlays removeAllObjects];
    [self.mapView removeOverlays:self.overlays];
}

- (IBAction)infoTableView:(id)sender
{
    [self performSegueWithIdentifier:@"infoTableView" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"infoTableView"])
    {
        InformationViewController *tela = [segue destinationViewController];
        
        tela.collors = self.colors;
        tela.busLine = self.bus;
    }
}


//Create a route(polyline), and add it to the map
- (void)addRoute: (NSArray *)route
{
    CLLocationCoordinate2D *coordinates = [route count] ? malloc(sizeof(CLLocationCoordinate2D)* [route count]) : NULL;
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
	
    route = [route sortedArrayUsingDescriptors:@[descriptor]];
	
    Polyline_points* point;
    NSInteger idx;
	for (idx = 0; idx < [route count]; idx++) {
		point = [route objectAtIndex:idx];
		coordinates[idx] = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
	}
    
    //Find initial bus stop
    CLLocationCoordinate2D initialPoint = [self findBusStopNear: self.mapView.userLocation.coordinate];
    NSLog(@"initial: %f %f", initialPoint.latitude, initialPoint.longitude);

    //Find final bus stop
    CLLocationCoordinate2D finalPoint = [self findBusStopNear: self.final];
    
    NSMutableArray* box1 = [[NSMutableArray alloc] init];
    NSMutableArray* box2 = [[NSMutableArray alloc] init];
    
    //Create geoBox for each point - initial and final
	for (int i = 0; i < 4; i++) {
        CLLocationCoordinate2D tempPoint1 = [CoreLocationExtension NewLocationFrom: initialPoint atDistanceInMeters:100 alongBearingInDegrees: i*90.0];
        CLLocationCoordinate2D tempPoint2 = [CoreLocationExtension NewLocationFrom: finalPoint atDistanceInMeters:100 alongBearingInDegrees: i*90.0];
        [box1 addObject:[[CLLocation alloc] initWithLatitude:tempPoint1.latitude longitude:tempPoint1.longitude]];
        [box2 addObject:[[CLLocation alloc] initWithLatitude:tempPoint2.latitude longitude:tempPoint2.longitude]];
    }
    
    //Index t indicates initial route point to draw
    NSInteger t = 0, f = 0;
    BOOL found = NO;
    for (t = 0; !found && t < [route count]; t++){
        found = [self point: coordinates[t] belongsToGeobox: box1];
    }
    
    //Index f indicates final route point to draw
    found = NO;
    for (f = 0; !found && f < [route count]; f++){
        found = [self point: coordinates[f] belongsToGeobox: box2];
    }

    
	if (coordinates) {
		MKPolyline *polyLine = [MKPolyline polylineWithCoordinates: coordinates count: [route count]];
		
        //MKPolyline *polyLine = [MKPolyline polylineWithCoordinates: coordinates+t-1 count: [route count]-t+1];
		
        //MKPolyline *polyLine = [MKPolyline polylineWithCoordinates: coordinates+t-1 count: f-t+1];
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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.colors removeAllObjects];
        TrajectoryPlanner *trajectory = [[TrajectoryPlanner alloc] init];
        self.bus = [[NSArray alloc] initWithArray:[trajectory planningFrom: initial to: final]];
        if ([self.bus count]) {
            NSMutableArray* busPoints = [[NSMutableArray alloc] init];
            for (Bus_line* line in self.bus) {
                [busPoints addObjectsFromArray:[Bus_points getBusLineStops:line]];
            }
            //Create destination pin
            MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:self.final];
            [annotation setTitle:@"Destino!"];
            [self.mapView addAnnotation:annotation];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (Bus_line *line in self.bus){
                    [self addRoute:  [line.polyline_ida allObjects]];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Trajeto não encontrado!"
                                                                message:@"Tente mudar as suas configurações de busca para algo mais abrangente."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

            });
            
        }
    });
	
}

-(void)requestdidFailWithError:(NSError *)error{
	NSLog(@"Error!");
}

-(void)viewDidUnload:(BOOL)animated{
    [self.colors removeAllObjects];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)justGotInfo{
	self.gotInfo = YES;
	[self setThingsOnMap:self.initial];
}

-(void)setThingsOnMap:(CLLocationCoordinate2D)userLocation{
	if ([self.mapView.overlays count]) {
		return;
	}
	[self.mapView setCenterCoordinate:userLocation animated:YES];
	MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span);
    
    [self.mapView setRegion: viewRegion animated:YES];
	[[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
	NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
	
	[[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:userLocation andFinalPoint:self.final withRange:[prefs integerForKey:@"SearchRadius"]];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
}

- (CLLocationCoordinate2D)findBusStopNear: (CLLocationCoordinate2D) point {
    
    NSMutableArray* geoBox = [[NSMutableArray alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    float range = [prefs integerForKey:@"SearchRadius"];
	
    for (int i = 0; i < 4; i++) {
		CLLocationCoordinate2D tempPoint = [CoreLocationExtension NewLocationFrom: point atDistanceInMeters:range alongBearingInDegrees:i*90.0];
        [geoBox addObject:[[CLLocation alloc] initWithLatitude:tempPoint.latitude longitude:tempPoint.longitude]];
    }
    NSMutableArray* stops = [[NSMutableArray alloc] initWithArray: [Bus_points getAllBusStopsWithinGeographicalBox: geoBox]];
    
    BOOL found = NO;
    int i = -1;
    //Search the bus stop with the selected bus (self.bus[0])
    while (!found){
        i++;
        found = [((Bus_points *) stops[i]).onibus_que_passam containsObject: self.bus[0]];
    }
    
    CLLocationCoordinate2D routePoint = CLLocationCoordinate2DMake(((Bus_points *) stops[i]).lat.doubleValue, ((Bus_points *) stops[i]).lng.doubleValue);
    
    return routePoint;
}

- (BOOL)point: (CLLocationCoordinate2D)point belongsToGeobox: (NSMutableArray *)box {
    CLLocation *N = box[0];
	CLLocation *E = box[1];
	CLLocation *S = box[2];
	CLLocation *W = box[3];
    
    NSLog(@"SUL: %f %f", S.coordinate.latitude, S.coordinate.longitude);
    NSLog(@"NORTE: %f %f", N.coordinate.latitude, N.coordinate.longitude);
    NSLog(@"OESTE: %f %f", W.coordinate.latitude, W.coordinate.longitude);
    NSLog(@"LESTE: %f %f", E.coordinate.latitude, E.coordinate.longitude);
    
    return (point.latitude < N.coordinate.latitude && point.latitude > S.coordinate.latitude && point.longitude > W.coordinate.longitude && point.longitude < E.coordinate.longitude);
}

@end
