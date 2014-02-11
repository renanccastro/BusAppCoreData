//
//  TabBarViewController.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 11/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
//	self.navigationController.navigationBarHidden = YES;
	// Do any additional setup after loading the view.
}
- (IBAction)planRoute:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"push"]) {
		[((id<SetInfo>)self.selectedViewController) setInfoForController:[segue destinationViewController]];

		
	}
}

@end
