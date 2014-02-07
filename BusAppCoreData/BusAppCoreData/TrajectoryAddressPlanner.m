//
//  TrajectoryAddressPlanner.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 05/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryAddressPlanner.h"
#import <CoreLocation/CoreLocation.h>
#import "TrajectoryViewController.h"

@interface TrajectoryAddressPlanner () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *bairro;
@property (nonatomic) CLLocationCoordinate2D final;
@property (nonatomic) CLGeocoder* geocoder;
@end

@implementation TrajectoryAddressPlanner

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)searchRoute:(id)sender {
	//Geocode the string, and send it to the next screen.
	[self.geocoder geocodeAddressString:[NSString stringWithFormat:@"Brasil, São Paulo, Campinas, %@, %@, %@",\
										 self.bairro.text ? self.bairro.text : @"",\
										 self.address.text ? self.address.text : @"",\
										 self.number.text ? self.number.text : @""]
	 
				 completionHandler:^(NSArray* placemarks, NSError* error){
					 self.final = ((CLPlacemark*)[placemarks firstObject]).location.coordinate;
					 [self performSegueWithIdentifier:@"addressPush" sender:self];
				 }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.geocoder = [[CLGeocoder alloc] init];
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	[self.view addGestureRecognizer:tap];
	// Do any additional setup after loading the view.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}
-(IBAction)dismissKeyboard:(id)sender{
	[self.address resignFirstResponder];
	[self.number resignFirstResponder];
	[self.bairro resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"addressPush"]) {
		TrajectoryViewController* vc = [segue destinationViewController];
		vc.final = self.final;
	}
}




@end
