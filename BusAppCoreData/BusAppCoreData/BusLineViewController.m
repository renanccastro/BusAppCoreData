//
//  BusLineViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 28/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusLineViewController.h"
#import <MapKit/MapKit.h>

@interface BusLineViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation BusLineViewController

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

//- (void)addRoute
//{
//    
//    CLLocationCoordinate2D coordinates[[self.mapView.annotations count]];
//    for (NSInteger index = 0; index < [self.mapView.annotations count]; index++) {
//        MKPlacemark *placeMark = [self.mapView.annotations objectAtIndex: index];
//        coordinates[index] = placeMark.coordinate;
//    }
//    
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:10];
//    [_mapView addOverlay:polyLine];
//}
//
//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
//{
//    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
//    polylineView.strokeColor = [UIColor blueColor];
//    polylineView.lineWidth = 5.0;
//    return polylineView;
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
