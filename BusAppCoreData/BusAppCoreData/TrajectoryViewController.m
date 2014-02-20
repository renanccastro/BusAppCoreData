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

		for (Bus_line *line in self.bus){
			[self addRoute:  [line.polyline_ida allObjects] withType: @"ida"];
			[self addRoute: [line.polyline_volta allObjects] withType: @"volta"];
		}
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Trajeto não encontrado!"
														message:@"Tente mudar as suas configurações de busca para algo mais abrangente."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];

	}
	
}
-(void)requestdidFailWithError:(NSError *)error{
	NSLog(@"Error!");
}
-(void)viewDidUnload:(BOOL)animated{
    [self.colors removeAllObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) justGotInfo{
	self.gotInfo = YES;
	if (self.gotUserLocation) {
		[self setThingsOnMap:self.mapView.userLocation];
	}
}
-(void) setThingsOnMap:(MKUserLocation*)userLocation{
	if ([self.mapView.overlays count]) {
		return;
	}
	[self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
	MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span);
    
    [self.mapView setRegion: viewRegion animated:YES];
	[[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
	NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
	
	[[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:userLocation.coordinate andFinalPoint:self.final withRange:[prefs integerForKey:@"SearchRadius"]];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	self.gotUserLocation = YES;
	if (self.gotInfo) {
		[self setThingsOnMap:userLocation];
	}
}


@end
