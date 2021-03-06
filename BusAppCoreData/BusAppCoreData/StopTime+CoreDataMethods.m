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
#import "Bus_line+Core_Data_Methods.h"

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
                                                          andLong:[[times objectForKey:@"lg"] doubleValue]];
    
        stopTime.stop = stop;
		stopTime.bus = [times objectForKey:@"Bus"];
        [((Bus_line*)[times objectForKey:@"Bus"]) addStoptimesObject:stopTime];
        [stop addStoptimesObject:stopTime];
		[((Bus_line*)times[@"Bus"]) addStoptimesObject:stopTime];
        [stop addOnibus_que_passamObject:times[@"Bus"]];
    }
    NSError * saveError;

    [[CoreDataAndRequestSupervisor startSupervisor].context save:&saveError];
    return saveError ? NO : YES;
}
+(NSArray*) getAllTimesForStop:(Bus_points*)stop andBus:(Bus_line*)bus{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"StopTime" inManagedObjectContext:context];
	
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time"
																 ascending:YES];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	request.sortDescriptors = @[descriptor];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"bus == %@ AND stop == %@", bus, stop];
	
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
	
	if (error){
		NSLog(@"error getting bus");
	}
	return array;
}

@end
