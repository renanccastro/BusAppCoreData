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

@interface TrajectoryPlanningViewController () <TreeDataRequestDelegate>

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
    [[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
    [[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:CLLocationCoordinate2DMake(-22.82142, -47.08771) andFinalPoint:CLLocationCoordinate2DMake(-22.82188, -47.06655) withRange:600];
	// Do any additional setup after loading the view.
}
-(void)requestDataDidFinishWithInitialArray:(NSArray *)initial andWithFinal:(NSArray *)final{
    
    TrajectoryPlanner *trajectory = [[TrajectoryPlanner alloc] init];
    NSArray *route = [[NSArray alloc] initWithArray:[trajectory planningFrom: initial to: final]];
	NSLog(@"%@, Caminho com %d onibus",route, [route count]);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
