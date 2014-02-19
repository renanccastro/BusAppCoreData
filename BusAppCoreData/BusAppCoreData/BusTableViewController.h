//
//  BusTableViewController.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 30/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bus_line+Core_Data_Methods.h"
#import "Bus_points.h"

@interface BusTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *busLinesInStop;
@property (nonatomic, strong) Bus_points* stop;

@end
