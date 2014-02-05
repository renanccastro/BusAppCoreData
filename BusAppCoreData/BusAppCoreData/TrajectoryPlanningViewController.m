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

@interface TrajectoryPlanningViewController ()

@property (nonatomic) NSArray *route;

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"pushTeste"]) {
		TrajectoryViewController *vc = ((TrajectoryViewController*)[segue destinationViewController]);
		vc.bus = [[NSArray alloc] initWithArray:self.route];
        NSLog (@"quantidde%d",[vc.bus count]);
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
