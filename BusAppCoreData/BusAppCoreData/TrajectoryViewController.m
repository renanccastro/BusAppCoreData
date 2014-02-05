//
//  TrajectoryViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryViewController.h"
#import <MapKit/MapKit.h>
#import "Polyline_points.h"
#import "TrajectoryPlanner.h"
#import "CoreDataAndRequestSupervisor.h"

@interface TrajectoryViewController () <MKMapViewDelegate, TreeDataRequestDelegate>
{
    UIColor *color;
    
}

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
    
}


- (void)addRoute: (NSArray *)route withType: (NSString *)type
{
    
    if ([type isEqualToString: @"ida"]){
        color = [[UIColor alloc] initWithRed: 1 green: 0 blue: 0 alpha:0.5];
    } else {
        color = [[UIColor alloc] initWithRed: 0 green: 0 blue: 1 alpha:0.5];
    }
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D)* [route count]);
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order"
																 ascending:YES];
	
    route = [route sortedArrayUsingDescriptors:@[descriptor]];
	Polyline_points* point;
	for (NSInteger index = 0; index < [route count]; index++) {
		point = [route objectAtIndex:index];
		coordinates[index] = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
	}
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[route count]];
	
//	dispatch_async(dispatch_get_main_queue(), ^{
		[self.mapView addOverlay:polyLine];
//	});
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
    polylineView.strokeColor = color;
    polylineView.lineWidth = 5.0;
    return polylineView;
}

-(void)requestDataDidFinishWithInitialArray:(NSArray *)initial andWithFinal:(NSArray *)final{
    
    TrajectoryPlanner *trajectory = [[TrajectoryPlanner alloc] init];
    self.bus = [[NSArray alloc] initWithArray:[trajectory planningFrom: initial to: final]];
	
    for (Bus_line *line in self.bus){
        [self addRoute: [line.polyline_ida allObjects] withType: @"ida"];
        [self addRoute: [line.polyline_volta allObjects] withType: @"volta"];
    }

//	NSLog(@"%@, Caminho com %d onibus",self.bus, [self.bus count]);
}
-(void)requestdidFailWithError:(NSError *)error{
	NSLog(@"Error!");
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
//    CLLocationCoordinate2D max, min;
//    max = min = CLLocationCoordinate2DMake(((Polyline_points *)self.rotaDeIda[0]).lat.doubleValue, ((Polyline_points *)self.rotaDeIda[0]).lng.doubleValue);
//    
//    for (Polyline_points *polyline in self.rotaDeIda) {
//        if (polyline.lat.doubleValue > max.latitude){
//            max = CLLocationCoordinate2DMake(polyline.lat.doubleValue, max.longitude);
//        } else if (polyline.lat.doubleValue < min.latitude){
//            min = CLLocationCoordinate2DMake(polyline.lat.doubleValue, min.longitude);
//        }
//        if (polyline.lng.doubleValue > max.longitude){
//            max = CLLocationCoordinate2DMake(max.latitude, polyline.lng.doubleValue);
//        } else if (polyline.lat.doubleValue < min.latitude){
//            min = CLLocationCoordinate2DMake(min.latitude, polyline.lng.doubleValue);
//        }
//    }
//    
//    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((max.latitude + min.latitude)/2, (max.longitude + min.longitude)/2);
//    
//    MKCoordinateSpan span = MKCoordinateSpanMake(max.latitude - min.latitude + 0.00001, max.longitude - min.longitude + 0.00001);
//    
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(centerCoord, span);
//    
//    [self.mapView setRegion: viewRegion animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	[[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
	[[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:userLocation.coordinate andFinalPoint:self.final withRange:600];
}
@end
