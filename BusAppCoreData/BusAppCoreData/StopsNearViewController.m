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
#import "BusTableViewController.h"
#import "Bus_points.h"
#import "Bus_line.h"
#import "BusPoitsRadiusViewController.h"
#import "PKRevealController.h"

@interface StopsNearViewController () <MKMapViewDelegate,PKRevealing>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) NSArray* stopsNear;
@property (nonatomic) NSArray* selectedAnnotationInfo;

@end

@implementation StopsNearViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;

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
    [self.revealController  touchesBegan:nil withEvent:nil];
    self.mapView.delegate = self;
    self.navigationController.revealController.delegate = self;
    
}
-(void)viewWillAppear:(BOOL)animated{
	self.mapView.showsUserLocation = YES;
	[super viewWillAppear:animated];
	
}
-(void)viewWillDisappear:(BOOL)animated{
	self.mapView.showsUserLocation = NO;
	[super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToPoints:(id)sender {
	//Get the references from the storyboard, and do the side bar.
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                           bundle:nil];
    UITableViewController *right = [mystoryboard instantiateViewControllerWithIdentifier:@"SearchConfigViewControllerId"];
    UINavigationController *front = [mystoryboard instantiateViewControllerWithIdentifier:@"SearchViewControllerId"];
    PKRevealController *revealView = [PKRevealController revealControllerWithFrontViewController:front
                                                                             rightViewController:right];
    
    front.revealController = revealView;
    [revealView setMinimumWidth:180.0
                   maximumWidth:244.0
              forViewController:right];
    revealView.delegate = self;
    [self presentViewController:revealView
                       animated:YES
                     completion:nil];
}

#pragma - MapView Methods
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

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - Button methods

//Call right side view quem the button is pressed
- (IBAction)showConfiguration:(id)sender
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];

}

#pragma mark - PKreveal delegate methods

//when the state change form the rightView to the frontView it reload the bus points on the map
-(void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)state
{
    if(state == PKRevealControllerShowsFrontViewController)
    {
        if(![self isStopsOnScreen]){
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            [[CoreDataAndRequestSupervisor startSupervisor] setDelegate:self];
            [[CoreDataAndRequestSupervisor startSupervisor] getAllBusPointsAsyncWithinDistance:[prefs integerForKey:@"Radius"]
                                                                                     fromPoint: self.mapView.userLocation.coordinate];
            self.isStopsOnScreen = YES;
        }
    }
    else if(state == PKRevealControllerShowsRightViewController)
    {
        self.isStopsOnScreen = NO;
    }
}

#pragma mark - annotation and map view methods

//Create annotations with data from requests
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
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
	if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        ((MKUserLocation *)annotation).title = @"My Current Location";
        return nil;  //return nil to use default blue dot view
    }
    
    return nil;
}


//Save selected annotation info
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
    NSNumber *index = [NSNumber numberWithInt:((Annotation*)view.annotation).index];
	
    self.selectedAnnotationInfo = [((Bus_points*)self.stopsNear[index.intValue]).onibus_que_passam allObjects];
    [self performSegueWithIdentifier: @"BusLines" sender:nil];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:region animated:YES];
	
	if(![self isStopsOnScreen]){
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
		[[CoreDataAndRequestSupervisor startSupervisor] setDelegate:self];
		[[CoreDataAndRequestSupervisor startSupervisor] getAllBusPointsAsyncWithinDistance:[prefs integerForKey:@"Radius"] fromPoint: userLocation.coordinate];
		self.isStopsOnScreen = YES;
	}
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"BusLines"])
    {
        BusTableViewController *tela = (BusTableViewController*)[segue destinationViewController];
        tela.busLinesInStop = self.selectedAnnotationInfo;
     }
}

#pragma - Request
- (void)requestdidFinishWithObject:(NSArray*)nearStops{
	self.stopsNear = nearStops;
	[self creatAnnotationsFromBusPointsArray:nearStops];
	
}

- (void)requestdidFailWithError:(NSError *)error{
	
}

@end
