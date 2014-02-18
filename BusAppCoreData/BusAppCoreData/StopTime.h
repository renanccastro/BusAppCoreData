//
//  StopTime.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 18/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line, Bus_points;

@interface StopTime : NSManagedObject

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) Bus_line *bus;
@property (nonatomic, retain) Bus_points *stop;

@end
