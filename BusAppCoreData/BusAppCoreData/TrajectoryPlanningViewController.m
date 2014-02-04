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

@interface TrajectoryPlanningViewController () <TreeDataRequestDelegate>

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
    [[CoreDataAndRequestSupervisor startSupervisor] setTreeDelegate:self];
    [[CoreDataAndRequestSupervisor startSupervisor] getRequiredTreeLinesWithInitialPoint:CLLocationCoordinate2DMake(-22.82151, -47.08802) andFinalPoint:CLLocationCoordinate2DMake(-22.83010, -47.07940) withRange:600];
	// Do any additional setup after loading the view.
}
-(void)requestDataDidFinishWithInitialArray:(NSArray *)initial andWithFinal:(NSArray *)final{
    
    TrajectoryPlanner *trajectory = [[TrajectoryPlanner alloc] init];
    self.route = [[NSArray alloc] initWithArray:[trajectory planningFrom: initial to: final]];
	NSLog(@"%@, Caminho com %d onibus", self.route, [self.route count]);
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"push"]) {
		TrajectoryViewController *vc = [segue destinationViewController];
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
