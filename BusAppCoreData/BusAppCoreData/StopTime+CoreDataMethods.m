//
//  StopTime+CoreDataMethods.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 18/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "StopTime+CoreDataMethods.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Bus_points+CoreDataMethods.h"

@implementation StopTime (CoreDataMethods)

+(BOOL)createBusStopTimeWithDictionary:(NSDictionary*)times
{
    
    for(NSNumber *time in [times objectForKey:@"times"])
    {
        StopTime *stopTime = [NSEntityDescription insertNewObjectForEntityForName:@"StopTime"
                                                       inManagedObjectContext:[CoreDataAndRequestSupervisor startSupervisor].context];
        
        stopTime.time = time;
    
        Bus_points *stop  = [Bus_points createBusPointFromBusLine:[times objectForKey:@"Bus"]
                                                          withLat:[[times objectForKey:@"lat"] doubleValue]
                                                          andLong:[[times objectForKey:@"ln"] doubleValue]];
    
        stopTime.stop = stop;
        [stop addStoptimesObject:stopTime];
        [stop addStoptimesObject:stopTime];
        
    }
    NSError * saveError;

    
    return saveError ? NO : YES;
}

@end
