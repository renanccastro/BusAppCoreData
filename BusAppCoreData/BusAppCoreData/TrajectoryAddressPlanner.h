//
//  TrajectoryAddressPlanner.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 05/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TabBarViewController.h"

@interface TrajectoryAddressPlanner : UIViewController <SetInfo>
@property (nonatomic) CLLocationCoordinate2D final;
@end
