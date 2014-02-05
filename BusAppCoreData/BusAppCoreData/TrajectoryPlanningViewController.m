//
//  TrajectoryPlanningViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryPlanningViewController.h"
#import "CoreDataAndRequestSupervisor.h"
#import "TrajectoryPlanner.h"
#import "TrajectoryViewController.h"
#import "PKRevealController.h"

@interface TrajectoryPlanningViewController () <PKRevealing>

@end

@implementation TrajectoryPlanningViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)configurations:(id)sender
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.rightViewController ];
}

@end
