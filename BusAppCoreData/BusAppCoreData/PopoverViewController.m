//
//  PopoverViewController.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 24/05/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()
@property (weak, nonatomic) IBOutlet UILabel *bus;
@property (weak, nonatomic) IBOutlet UILabel *radius;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *walkingDistance;
@property (weak, nonatomic) IBOutlet UISlider *walkSlider;
@property (weak, nonatomic) IBOutlet UIStepper *busStepper;

@end

@implementation PopoverViewController

- (IBAction)searchRadiusChanged:(UISlider*)sender {
    self.radius.text = [NSString stringWithFormat:@"%.0fm", [sender value]];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Radius"];
	[[NSUserDefaults standardUserDefaults] synchronize];


}
- (IBAction)walkingDistanceChanged:(UISlider*)sender {
    //change the value of the radius of search  for bus stops
    int radius = [sender value];
    self.walkingDistance.text = [NSString stringWithFormat:@"%dm",radius];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"SearchRadius"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}
- (IBAction)busNumbersChanged:(UIStepper*)sender {
    int bus = [sender value];
    self.bus.text = [NSString stringWithFormat:@"%d",bus];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Bus"];
	[[NSUserDefaults standardUserDefaults] synchronize];

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
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    self.radiusSlider.value = [prefs integerForKey:@"Radius"];
    self.radius.text = [NSString stringWithFormat:@"%ldm", (long)[prefs integerForKey:@"Radius"]];
	self.walkSlider.value = [prefs integerForKey:@"SearchRadius"];
    self.walkingDistance.text = [NSString stringWithFormat:@"%ldm", (long)[prefs integerForKey:@"SearchRadius"]];
    self.busStepper.value = [prefs integerForKey:@"Bus"];
    self.bus.text = [NSString stringWithFormat:@"%ld",(long)[prefs integerForKey:@"Bus"]];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
