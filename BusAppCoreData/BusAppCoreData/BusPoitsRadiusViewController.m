//
//  BusPoitsRadiusViewController.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusPoitsRadiusViewController.h"

@interface BusPoitsRadiusViewController () 
@property (weak, nonatomic) IBOutlet UILabel *radiusText;
@property (weak, nonatomic) IBOutlet UIStepper *radiusChange;
@property (weak, nonatomic) IBOutlet UIStepper *howMuchBus;
@property (weak, nonatomic) IBOutlet UIStepper *radiusIncrement;
@property (weak, nonatomic) IBOutlet UILabel *radius;
@property (weak, nonatomic) IBOutlet UILabel *bus;


@end

@implementation BusPoitsRadiusViewController

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
    
    //just update the label and the value onthe steper to the value in user preferences
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    self.radiusChange.value = [prefs integerForKey:@"Radius"];
    self.radiusText.text = [NSString stringWithFormat:@"%ldm", (long)[prefs integerForKey:@"Radius"]];
	self.radiusIncrement.value = [prefs integerForKey:@"SearchRadius"];
    self.radius.text = [NSString stringWithFormat:@"%ldm", (long)[prefs integerForKey:@"SearchRadius"]];
    self.howMuchBus.value = [prefs integerForKey:@"Bus"];
    self.bus.text = [NSString stringWithFormat:@"%ld",(long)[prefs integerForKey:@"Bus"]];

	
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)distanceChanged:(UIStepper*)sender {
	//change the value of the radius of search  for bus stops
    int radius = [sender value];
    self.radius.text = [NSString stringWithFormat:@"%dm",radius];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"SearchRadius"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)busChanged:(UIStepper*)sender {
	int bus = [sender value];
    self.bus.text = [NSString stringWithFormat:@"%d",bus];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Bus"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)radiusChanged:(UIStepper*)sender
{
    //change the value of the radius of search  for bus stops
    self.radiusCount = [sender value];
    self.radiusText.text = [NSString stringWithFormat:@"%dm", self.radiusCount];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Radius"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end
