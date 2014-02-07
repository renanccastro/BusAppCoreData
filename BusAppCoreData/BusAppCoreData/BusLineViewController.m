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
#import "Bus_points+CoreDataMethods.h"
#import "Annotation.h"

@interface BusLineViewController () <MKMapViewDelegate, UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) NSArray* annotations;

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
	[self.activityIndicator startAnimating];
	self.webPage.hidden = YES;
	self.navigationItem.title = self.bus_line.full_name;
	self.annotations = [[NSArray alloc] init];
	self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    int webCode = self.bus_line.web_number.intValue;
    
    self.webPage.scalesPageToFit = YES;
	NSLog(@"%d", webCode);
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.emdec.com.br/ABusInf/detalhelinha.asp?TpDiaID=0&CdPjOID=%d", webCode];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webPage loadRequest:requestObj];

}

//Create a polyline from the self.rotaDeVolta e self.rotaDeIda.
- (void)addRouteWithType: (NSString *)type
{
    NSArray *route;
	
	if (self.color == nil) {
		if ([type isEqualToString: @"ida"]){
			route = self.rotaDeIda;
			self.color = [[UIColor alloc] initWithRed: 1 green: 0 blue: 0 alpha:0.5];
		} else {
			self.color = [[UIColor alloc] initWithRed: 0 green: 0 blue: 1 alpha:0.5];
		}
	}
	if ([type isEqualToString:@"volta"]) {
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
	//Refresh the annotations already on the map
	if (self.mapView.annotations){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations){
        [self.mapView addAnnotations: self.annotations];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

//Add a polyline view to the mapView
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline: overlay];
    polylineView.strokeColor = self.color;
    polylineView.lineWidth = 5.0;
    return polylineView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
	//Remove frames from the EMDEC website, so the user can get more useful information.
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('mapFrame').style.display='none'; document.getElementById('topo').style.display='none'; var elements = document.getElementsByClassName('bgAzulClaro'); elements[0].style.display = 'none'; var myList = document.getElementsByTagName('table'); a = myList.length; myList[0].style.display = 'none'; myList[1].style.display = 'none'; myList[a-1].style.display = 'none'; myList[a-2].style.display = 'none'; myList[a-3].style.display = 'none'; myList[a-4].style.display = 'none';document.getElementById('conteiner').style.width = '100%'; document.getElementById('conteiner').style.float='left'; document.getElementById('conteiner').style.marginTop='0px';"];
	[self.activityIndicator stopAnimating];
	webView.hidden = NO;
}


//Create annotations from an array of bus points.
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

	[self setAnnotations:annotationArray];
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


//Remove old annotations and set new ones

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	[self addRouteWithType: @"ida"];
    [self addRouteWithType: @"volta"];

	[self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
	
	[self creatAnnotationsFromBusPointsArray:[Bus_points getBusLineStops:self.bus_line]];
    
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
@end
