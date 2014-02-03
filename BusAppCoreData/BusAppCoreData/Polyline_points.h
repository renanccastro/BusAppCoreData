//
//  Polyline_points.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line;

@interface Polyline_points : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Bus_line *linha_ida;
@property (nonatomic, retain) Bus_line *linha_volta;

@end
