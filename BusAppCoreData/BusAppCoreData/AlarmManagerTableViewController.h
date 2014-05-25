//
//  AlarmManagerTableViewController.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 25/05/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopTime.h"

@interface AlarmManagerTableViewController : UITableViewController
@property (nonatomic) StopTime* busTime;
@end
