//
//  Bus_points+CoreDataMethods.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Bus_points+CoreDataMethods.h"
#import "Bus_line.h"
#import "CoreDataAndRequestSupervisor.h"

@implementation Bus_points (CoreDataMethods)

//Return all stops from one bus line
+(NSArray*) getBusLineStops:(Bus_line*)bus_line{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_points" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"ANY onibus_que_passam.web_number == %d", [bus_line.web_number integerValue]];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];

	if (error){
		NSLog(@"error getting bus");
	}
	return array;
}


//get bus stop with lat and lng
+(Bus_points*) getBusPointWithLatitude:(double)lat withLongitude:(double)lng{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Bus_points"
                                                         inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
    
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf",lat, lng];
	[request setPredicate:predicate];
    
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	
	return [array firstObject];
}

//Create a bus point from bus line, check if there`s already a point and return it.
+(Bus_points*) createBusPointFromBusLine:(Bus_line*)bus withLat:(double)lat andLong:(double)lng{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSNumber * lat_number = [NSNumber numberWithDouble:lat];
	NSNumber * lng_number = [NSNumber numberWithDouble:lng];
	NSError* error = nil;
	
	Bus_points* stop=[Bus_points getBusPointWithLatitude:lat withLongitude:lng];
	
	if (!stop) {
		//Create a new bus_point
		stop = [NSEntityDescription insertNewObjectForEntityForName:@"Bus_points"
                                             inManagedObjectContext:context];
		stop.lat = lat_number;
		stop.lng = lng_number;
		
		[stop addOnibus_que_passamObject:bus];
	}
	else{
		if (![stop.onibus_que_passam containsObject:bus]) {
			[stop addOnibus_que_passamObject:bus];
		}
	}

	[context save:&error];
	
	return error == nil ? stop : nil;
}


@end
