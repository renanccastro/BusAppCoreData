//
//  TrajectoryPlanningViewController.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRevealController.h"

@interface TrajectoryPlanningViewController : UIViewController <PKRevealing>

@property (nonatomic, strong) PKRevealController *revealController;

@end
