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
{
    UIColor *color;

}

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
	[self addRouteWithType: @"ida"];
    [self addRouteWithType: @"volta"];

    
//    [self activateorientation];
    
}

- (void)addRouteWithType: (NSString *)type
{
    NSArray *route;

    if ([type isEqualToString: @"ida"]){
        route = self.rotaDeIda;
        color = [[UIColor alloc] initWithRed: 1 green: 0 blue: 0 alpha:0.5];
    } else {
        color = [[UIColor alloc] initWithRed: 0 green: 0 blue: 1 alpha:0.5];
        if (![self.rotaDeVolta count]){
            route = self.rotaDeIda;
        }
    }
    CLLocationCoordinate2D *coordinates = [route count] ? malloc(sizeof(CLLocationCoordinate2D)* [route count]) : NULL;
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order"
																 ascending:YES];
	
    
    route = [route sortedArrayUsingDescriptors:@[descriptor]];
	Polyline_points* point;
	for (NSInteger index = 0; index < [route count]; index++) {
		point = [route objectAtIndex:index];
		coordinates[index] = CLLocationCoordinate2DMake(point.lat.doubleValue, point.lng.doubleValue);
	}

    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[route count]];
	free(coordinates);
    [_mapView addOverlay:polyLine];
}


- (void)updateMapView
{
    if (self.mapView.overlays){
        [self.mapView removeOverlays: self.mapView.overlays];
    }
    if (self.rotaDeIda || self.rotaDeVolta){
//        [self addRoute];
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
    polylineView.strokeColor = color;
    polylineView.lineWidth = 5.0;
    return polylineView;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
    CLLocationCoordinate2D max, min;
    max = min = CLLocationCoordinate2DMake(((Polyline_points *)self.rotaDeIda[0]).lat.doubleValue, ((Polyline_points *)self.rotaDeIda[0]).lng.doubleValue);
    
    for (Polyline_points *polyline in self.rotaDeIda) {
        if (polyline.lat.doubleValue > max.latitude){
            max = CLLocationCoordinate2DMake(polyline.lat.doubleValue, max.longitude);
        } else if (polyline.lat.doubleValue < min.latitude){
            min = CLLocationCoordinate2DMake(polyline.lat.doubleValue, min.longitude);
        }
        if (polyline.lng.doubleValue > max.longitude){
            max = CLLocationCoordinate2DMake(max.latitude, polyline.lng.doubleValue);
        } else if (polyline.lat.doubleValue < min.latitude){
            min = CLLocationCoordinate2DMake(min.latitude, polyline.lng.doubleValue);
        }
    }
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((max.latitude + min.latitude)/2, (max.longitude + min.longitude)/2);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(max.latitude - min.latitude + 0.00001, max.longitude - min.longitude + 0.00001);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(centerCoord, span);
    
    [self.mapView setRegion: viewRegion animated:YES];
    
}

#pragma - NAO APAGUE AINDA :P
-(void) activateorientation{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self										 selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


#define degreesToRadian(x) (M_PI * (x) / 180.0)


- (void) didRotate:(NSNotification *)notification
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
	if (orientation == UIDeviceOrientationLandscapeLeft)
	{
        // implement here
	}
	if (orientation == UIDeviceOrientationLandscapeRight)
	{
        // implement here
        CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(degreesToRadian(90));
        
        
        
        landscapeTransform = CGAffineTransformTranslate (landscapeTransform, 0.0, 0.0);
        
        //        self.view.bounds = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 480, 320);
        
        //
        
        //
        
        //        [self.view setTransform:landscapeTransform];
        
        
        
//        [self.webPage setTransform:landscapeTransform];
//        [self.mapView setTransform: landscapeTransform];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('mapFrame').style.display='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('tituloTopo').style.display='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('portMenu').style.display='none';"];
	
//	NSString* removeALL = @"var all = document.getElementsByTagName('*');\
//	for (var i = 0; i < all.length; i++) {\
//			all[i].style.display = 'none';\
//	}\
//	document.getElementById('tabs').style.display = 'inline';";
//	[webView stringByEvaluatingJavaScriptFromString:removeALL];

//	NSString * removeTables = @"var tables=document.getElementById('conteiner').getElementsByTagName('table');\
//								for(var i = 0 ; i > tables.length; i++){\
//										tables[i].style.display='none';\
//								}";
//		   [webView stringByEvaluatingJavaScriptFromString:removeTables];

}
@end
