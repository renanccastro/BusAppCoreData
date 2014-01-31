//
//  BusLineViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 28/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusLineViewController.h"
#import "Polyline_points.h"
#import <MapKit/MapKit.h>

@interface BusLineViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation BusLineViewController

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
    
    int webCode = 3;
    
    self.webPage.scalesPageToFit = YES;
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.emdec.com.br/ABusInf/detalhelinha.asp?TpDiaID=0&CdPjOID=%d", webCode];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webPage loadRequest:requestObj];
    
}

- (void)addRoute
{
    
    CLLocationCoordinate2D coordinates[[self.rotaDeIda count]];
    for (NSInteger index = 0; index < [self.rotaDeIda count]; index++) {
        Polyline_points *point = [self.rotaDeIda objectAtIndex: index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count: [self.rotaDeIda count]];
    [_mapView addOverlay:polyLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}

- (void)updateMapView
{
    if (self.mapView.overlays){
        [self.mapView removeOverlays: self.mapView.overlays];
    }
    if (self.rotaDeIda){
        [self addRoute];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 1000, 1000);
    [self.mapView setRegion: viewRegion animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
