//
//  PinDropViewController.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "PinDropViewController.h"
#import "Annotation.h"
#import "TrajectoryViewController.h"
#import	<MapKit/MapKit.h>

@interface PinDropViewController () <MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic) CLLocationCoordinate2D pinLocation;
@property (nonatomic) CLLocationCoordinate2D initial;

@end

@implementation PinDropViewController

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
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
	[self.mapView addGestureRecognizer:lpgr];
	[self.mapView setDelegate:self];

	// Do any additional setup after loading the view.
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
	
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
	CLLocationCoordinate2D touchMapCoordinate =
	[self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	
	self.pinLocation = touchMapCoordinate;
	
    Annotation *annot = [[Annotation alloc] init];
    annot.coordinate = touchMapCoordinate;
	annot.title = @"Destination Point";
	
	self.initial = self.mapView.userLocation.coordinate;
	
    [self.mapView addAnnotation:annot];
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"push"]) {
		TrajectoryViewController *vc = [segue destinationViewController];
		vc.initial = self.initial;
		vc.final = self.pinLocation;
	}
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	[self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.008, 0.008);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span);
    
    [self.mapView setRegion: viewRegion animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
