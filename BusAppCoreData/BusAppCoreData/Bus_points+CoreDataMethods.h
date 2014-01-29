//
//  Bus_points+CoreDataMethods.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Bus_points.h"

@interface Bus_points (CoreDataMethods)
+(Bus_points*) getBusPointWithLatitude:(double)lat withLongitude:(double)lng;
+(NSArray*) getBusLineStops:(Bus_line*)bus_line;


@end
