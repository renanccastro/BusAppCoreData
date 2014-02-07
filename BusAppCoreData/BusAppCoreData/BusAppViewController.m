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
#import "PKRevealController.h"
@interface BusAppViewController () <PKRevealing>

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

-(void)viewWillAppear:(BOOL)animated{
	self.navigationController.navigationBar.hidden = YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rotePlaningView:(id)sender
{
	//Get the references from the storyboard, and do the side bar.
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                           bundle:nil];
    UITableViewController *right = [mystoryboard instantiateViewControllerWithIdentifier:@"SearchConfigViewControllerId"];
    UINavigationController *front = [mystoryboard instantiateViewControllerWithIdentifier:@"SearchViewControllerId"];
    PKRevealController *revealView = [PKRevealController revealControllerWithFrontViewController:front
                                                                             rightViewController:right];
    
    front.revealController = revealView;
    [revealView setMinimumWidth:180.0
                   maximumWidth:244.0
              forViewController:right];
    revealView.delegate = self;
    [self presentViewController:revealView
                       animated:YES
                     completion:nil];
    
    
}

- (IBAction)stopsView:(id)sender
{
	//Same as above.
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                           bundle:nil];
    UITableViewController *right = [mystoryboard instantiateViewControllerWithIdentifier:@"RightViewControllerId"];
    UINavigationController *front = [mystoryboard instantiateViewControllerWithIdentifier:@"NavigationControllerId"];
    PKRevealController *revealView  = [PKRevealController revealControllerWithFrontViewController:front
                                                                               rightViewController:right];
    
    front.revealController = revealView;
    [revealView setMinimumWidth:180.0
                   maximumWidth:244.0
              forViewController:right];
    
    revealView.delegate = self;
    [self presentViewController:revealView
                       animated:YES
                     completion:nil];
}




@end
