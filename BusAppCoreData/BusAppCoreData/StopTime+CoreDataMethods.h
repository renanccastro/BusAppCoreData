//
//  StopTime+CoreDataMethods.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 18/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "StopTime.h"

@interface StopTime (CoreDataMethods)

+(BOOL)createBusStopTimeWithDictionary:(NSDictionary*)times;
+(NSArray*) getAllTimesForStop:(Bus_points*)stop andBus:(Bus_line*)bus;

@end
