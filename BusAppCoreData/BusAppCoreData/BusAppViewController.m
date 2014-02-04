//
//  BusAppViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusAppViewController.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Bus_line+Core_Data_Methods.h"
#import <CoreLocation/CoreLocation.h>
#import "StopsNearViewController.h"
@interface BusAppViewController ()

@end

@implementation BusAppViewController

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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"stopsNearSegue"]) {
		StopsNearViewController* vc = [segue destinationViewController];
		vc.isStopsOnScreen = NO;
	}
}

-(void)exemplo{
	
}




@end
