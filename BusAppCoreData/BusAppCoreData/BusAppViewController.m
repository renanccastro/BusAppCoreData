//
//  BusAppViewController.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusAppViewController.h"
#import "CoreDataAndRequestSupervisor.h"

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
    
    CoreDataAndRequestSupervisor *supervisor = [CoreDataAndRequestSupervisor startSupervisor];
    
    [supervisor requestBusLines];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
