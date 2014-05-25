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
#import "TrajectoryViewController.h"
#import "FPPopoverController.h"
#import <AddressBookUI/AddressBookUI.h>



@interface StopsNearViewController () <MKMapViewDelegate,PKRevealing, UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate, FPPopoverControllerDelegate> {
    NSArray *searchResultPlaces;
    MKPointAnnotation *selectedPlaceAnnotation;
    BOOL shouldBeginEditing;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MKPointAnnotation* pinAnnotation;
@property (nonatomic) CLLocationCoordinate2D initial;
@property (nonatomic) NSArray* stopsNear;
@property (nonatomic) NSArray* selectedAnnotationInfo;
@property (nonatomic, strong) Bus_points* selectedStop;
@property (nonatomic) CLGeocoder* geocoder;
@property (nonatomic) NSArray* placemarks;
@end

@implementation StopsNearViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
- (IBAction)configPopover:(id)sender {
    //the view controller you want to present as popover
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                             bundle: nil];
    
    UIViewController *controller = (UIViewController*)[mainStoryboard
                                                       instantiateViewControllerWithIdentifier: @"popoverContent"];
    
    //our popover
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    
    //the popover will be presented from the okButton view
    [popover presentPopoverFromView:sender];
    popover.delegate = self;
    
    //no release (ARC enable)
    //[controller release];
}
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    int radius = [prefs integerForKey:@"Radius"];
    [[CoreDataAndRequestSupervisor startSupervisor] setDelegate:self];
    [[CoreDataAndRequestSupervisor startSupervisor] getAllBusPointsAsyncWithinDistance:radius fromPoint: self.mapView.userLocation.coordinate];
    self.isStopsOnScreen = YES;
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
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	UILocalNotification* n1 = [[UILocalNotification alloc] init];
	n1.fireDate = [NSDate dateWithTimeIntervalSinceNow: 10];
	[n1 setAlertAction:@"teste"]; //The button's text that launches the application and is shown in the alert
	[n1 setAlertBody:@""]; //Set the message in the notification from the textField's text
	n1.soundName = UILocalNotificationDefaultSoundName;
	[n1 setHasAction: YES]; //Set that pushing the button will launch the application
	[[UIApplication sharedApplication] scheduleLocalNotification: n1];

	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
	[self.mapView addGestureRecognizer:lpgr];
	[self.mapView setDelegate:self];

	
	// Do any additional setup after loading the view.
	self.placemarks = [[NSArray alloc] init];
    self.mapView.delegate = self;
    self.navigationController.revealController.delegate = self;
	self.geocoder = [[CLGeocoder alloc] init];
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

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
		
	if(self.pinAnnotation)
		[self.mapView removeAnnotation:self.pinAnnotation];
	
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
	CLLocationCoordinate2D touchMapCoordinate =
	[self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    NSLog(@"\n\nLOCATION pin : %f %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);

		
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
	annot.title = @"Destination Point";
	self.pinAnnotation = annot;
	
	self.initial = self.mapView.userLocation.coordinate;
	
    [self.mapView addAnnotation:annot];
	
}

#pragma - MapView Methods
//Remove old annotations and set new ones
//- (void)updateMapView
//{
//    if (self.mapView.annotations){
//        [self.mapView removeAnnotations:self.mapView.annotations];
//    }
//    if (self.annotations){
//        [self.mapView addAnnotations: self.annotations];
//    }
////    [_mapView setCenterCoordinate:[_mapView centerCoordinate] animated:NO];
//}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
//    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    
    _annotations = annotations;
//    [self updateMapView];
}

#pragma mark - Button methods


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
	[self.mapView removeAnnotations:self.mapView.annotations];
    dispatch_async (dispatch_get_main_queue(), ^
    {
        [self.mapView addAnnotations:annotationArray];
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        int radius = [prefs integerForKey:@"Radius"];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, radius+800, radius+800);
        [self.mapView setRegion:region animated:YES];
        
    });

}

//Configure annotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"myAnnotation2";
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
	else{
		MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
		if (!annotationView) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		}
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
		
		UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[detailButton addTarget:self action:@selector(annotationDetailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		annotationView.rightCalloutAccessoryView = detailButton;

	}
    
    return nil;
}
- (void)annotationDetailButtonPressed:(id)sender {
    // Detail view controller application logic here.
}



//Save selected annotation info
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
    NSNumber *index = [NSNumber numberWithInt:((Annotation*)view.annotation).index];
	
    self.selectedAnnotationInfo = [((Bus_points*)self.stopsNear[index.intValue]).onibus_que_passam allObjects];
	
	self.selectedStop = self.stopsNear[index.intValue];
    [self performSegueWithIdentifier: @"BusLines" sender:nil];
    
}

-(void) updateUserLocationAndGetBusStopsWithLocation:(CLLocationCoordinate2D)location{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    int radius = [prefs integerForKey:@"Radius"];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, radius+50, radius+50);
    [self.mapView setRegion:region animated:YES];
    
    [[CoreDataAndRequestSupervisor startSupervisor] setDelegate:self];
    [[CoreDataAndRequestSupervisor startSupervisor] getAllBusPointsAsyncWithinDistance:radius fromPoint: location];
    self.isStopsOnScreen = YES;

}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	if(![self isStopsOnScreen]){
        [self updateUserLocationAndGetBusStopsWithLocation:userLocation.location.coordinate];
	}
}

#pragma - Request
- (void)requestdidFinishWithObject:(NSArray*)nearStops{
    @synchronized(self)
    {
        self.stopsNear = nearStops;
        [self creatAnnotationsFromBusPointsArray:nearStops];
	}
}

- (void)requestdidFailWithError:(NSError *)error{
	
}


- (IBAction)recenterMapToUserLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = self.mapView.userLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.placemarks count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
	CLPlacemark* placemark = ((CLPlacemark*)self.placemarks[indexPath.row]);
	NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@", "];
    cell.textLabel.text = addressString;

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLPlacemark *place = ((CLPlacemark*)self.placemarks[indexPath.row]);
	[self addPlacemarkAnnotationToMap:place addressString:place.description];
	[self recenterMapToPlacemark:place];
//	[self dismissSearchControllerWhileStayingActive];
	[self.searchDisplayController setActive:NO animated:YES];
	[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:self.pinAnnotation];
    
    self.pinAnnotation = [[MKPointAnnotation alloc] init];
    self.pinAnnotation.coordinate = placemark.location.coordinate;
    self.pinAnnotation.title = address;
    [self.mapView addAnnotation:self.pinAnnotation];
}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
//	self.searchDisplayController.searchResultsTableView.hidden = YES;
//	self.searchDisplayController.searchResultsTableView.userInteractionEnabled = NO;
	[self.mapView becomeFirstResponder];
    [self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar resignFirstResponder];
}


#pragma mark -
#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
		[self.geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
			self.placemarks = placemarks ? placemarks : self.placemarks;
			NSLog(@"%@",((CLPlacemark*)placemarks.firstObject).name);
			NSLog(@"%@",self.placemarks);
			[self.searchDisplayController.searchResultsTableView reloadData];
		}];
		return YES;
    // Return YES to cause the search result table view to be reloaded.
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
		self.mapView.showsUserLocation = NO;
		self.mapView.showsUserLocation = YES;
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 0.75;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}


#pragma mark -
#pragma mark InfoPassing

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"BusLines"])
    {
        BusTableViewController *tela = (BusTableViewController*)[segue destinationViewController];
        tela.busLinesInStop = self.selectedAnnotationInfo;
		tela.stop = self.selectedStop;
	}
	if ([[segue identifier] isEqualToString:@"searchPush"]) {
		TrajectoryViewController * vc = [segue destinationViewController];
		vc.final = self.pinAnnotation.coordinate;
		vc.initial = self.mapView.userLocation.coordinate;
	}
}



@end
