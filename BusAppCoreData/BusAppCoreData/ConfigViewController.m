//
//  ConfigViewController.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 05/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "ConfigViewController.h"

@interface ConfigViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *howMuchBus;
@property (weak, nonatomic) IBOutlet UIStepper *radiusIncrement;
@property (weak, nonatomic) IBOutlet UILabel *radius;
@property (weak, nonatomic) IBOutlet UILabel *bus;

@end

@implementation ConfigViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    self.radiusIncrement.value = [prefs integerForKey:@"SearchRadius"];
    self.radius.text = [NSString stringWithFormat:@"%dm", [prefs integerForKey:@"SearchRadius"]];
    self.howMuchBus.value = [prefs integerForKey:@"Bus"];
    self.bus.text = [NSString stringWithFormat:@"%d",[prefs integerForKey:@"Bus"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)radiusChange:(UIStepper*)sender
{
    //change the value of the radius of search  for bus stops
    int radius = [sender value];
    self.radius.text = [NSString stringWithFormat:@"%dm",radius];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"SearchRadius"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)busChange:(UIStepper*)sender
{
    int bus = [sender value];
    self.bus.text = [NSString stringWithFormat:@"%d",bus];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[sender value]
               forKey:@"Bus"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
