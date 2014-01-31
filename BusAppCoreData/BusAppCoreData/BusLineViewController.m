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
#import "Polyline_points.h"

@interface BusLineViewController () <MKMapViewDelegate, UIWebViewDelegate>

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
    
    int webCode = self.bus_line.web_number.intValue;
    
    self.webPage.scalesPageToFit = YES;
	NSLog(@"%d", webCode);
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.emdec.com.br/ABusInf/detalhelinha.asp?TpDiaID=0&CdPjOID=%d", webCode];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webPage loadRequest:requestObj];
	[self addRoute];
    
}

- (void)addRoute
{
	//    CLLocationCoordinate2D coordinates[[self.mapView.annotations count]];
	//    for (NSInteger index = 0; index < [self.mapView.annotations count]; index++) {
	//        MKPlacemark *placeMark = [self.mapView.annotations objectAtIndex: index];
	//        coordinates[index] = placeMark.coordinate;
	//    }
	CLLocationCoordinate2D* coordinates = malloc(sizeof(CLLocationCoordinate2D)* [self.rotaDeIda count]);
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order"
																 ascending:YES];
	self.rotaDeIda = [self.rotaDeIda sortedArrayUsingDescriptors:@[descriptor]];
	//	NSMutableArray* coordinates = [[NSMutableArray alloc] init];
	Polyline_points* point;
	for (NSInteger index = 0; index < [self.rotaDeIda count]; index++) {
		point = [self.rotaDeIda objectAtIndex:index];
		coordinates[index] = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
	}

	for (Polyline_points* point in self.rotaDeIda) {
		NSLog(@"ordem:%d", point.order.integerValue);
	}

    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[self.rotaDeIda count]];
    [_mapView addOverlay:polyLine];
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
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

-(void)webViewDidFinishLoad:(UIWebView *)webView{
	   [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('mapFrame').style.display='none';"];
//	NSString * removeTables = @"var tables=document.getElementById('conteiner').getElementsByTagName('table');\
//								for(var i = 0 ; i > tables.length; i++){\
//										tables[i].style.display='none';\
//								}";
//		   [webView stringByEvaluatingJavaScriptFromString:removeTables];

	
}
@end
