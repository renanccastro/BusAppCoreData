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
    self.radiusText.text = [NSString stringWithFormat:@"%dm", [prefs integerForKey:@"Radius"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)radiusChanged:(UIStepper*)sender
{
    //change the value of the radius of search  for bus stops
    self.radius = [sender value];
    self.radiusText.text = [NSString stringWithFormat:@"%dm", self.radius];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Radius"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end
