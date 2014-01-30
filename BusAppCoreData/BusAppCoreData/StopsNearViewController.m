//
//  StopsNearViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "StopsNearViewController.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Annotation.h"

@interface StopsNearViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation StopsNearViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;

-(void)updateMapView
{
    if (self.mapView.annotations){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations){
        [self.mapView addAnnotations: self.annotations];
        [self addOverlay];
    }
    
}

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

-(void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"myAnnotation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];//UIButtonTypeInfoDark];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    [self performSegueWithIdentifier: @"info" sender:nil];
}

- (void)addOverlay
{
    
    CLLocationCoordinate2D coordinates[10];
    for (NSInteger index = 0; index < 10; index++) {
        MKPlacemark *placeMark = [self.mapView.annotations objectAtIndex: index];
        coordinates[index] = placeMark.coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:10];
    [_mapView addOverlay:polyLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:
                                    overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView; 
}

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
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    int a;
    for (a = 0; a < 10; a++){
        Annotation* i = [[Annotation alloc]init];
        [i setSubtitle: [NSString stringWithFormat: @"ahh%d", a]];
        [i setTitle: [NSString stringWithFormat: @"title%d", a]];
        [i setCoordinate: CLLocationCoordinate2DMake([[NSString stringWithFormat: @"-22.97%d", a] doubleValue], [[NSString stringWithFormat: @"-47.063%d", a] doubleValue])];
        [temp addObject: i];
        
    }
    [self setAnnotations: temp];
    
}

- (void)viewWillAppear:(BOOL)animated {
    // Initial location
    CLLocationCoordinate2D initialLocation;
    initialLocation.latitude = -22.970100;
    initialLocation.longitude= -47.063200;
    
    // Specifying the region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(initialLocation, 4000, 4000);
    [_mapView setRegion:viewRegion animated:YES];
//    [self displayingStops];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	[[CoreDataAndRequestSupervisor startSupervisor] setDelegate:self];
	[[CoreDataAndRequestSupervisor startSupervisor] getAllBusPointsAsyncWithinDistance:100.0 fromPoint:userLocation.coordinate];
}

-(void)requestdidFinishWithObject:(NSArray*)nearStops{
	NSLog(@"%@",nearStops);
}
-(void)requestdidFailWithError:(NSError *)error{
	
}

@end
