//
//  TrajectoryViewController.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bus_line.h"

@interface TrajectoryViewController : UIViewController

@property (nonatomic, strong) NSArray *bus;

- (void)addRoute: (NSArray *)route withType: (NSString *)type;

@end
