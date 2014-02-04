//
//  Interception.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line, Bus_points;

@interface Interception : NSManagedObject

@property (nonatomic, retain) Bus_line *bus;
@property (nonatomic, retain) Bus_points *stop;

@end
