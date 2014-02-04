//
//  Interception+CoreDataMethods.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Interception+CoreDataMethods.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Bus_points.h"
#import "Bus_line.h"

@implementation Interception (CoreDataMethods)

//Create a interception with 2 bus lines and a point.
+(Interception*) createInterceptionForBus:(Bus_line*)line withInterceptionBus:(Bus_line*)bus withPoint:(Bus_points*)stop{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSError* error = nil;
	
	//Create a new bus_point
	Interception * inter = [NSEntityDescription insertNewObjectForEntityForName:@"Interception"
										 inManagedObjectContext:context];
	inter.bus = bus;
	//[inter setValue:bus forKey:@"bus"];
	inter.stop = stop;
	//[stop addInterceptionsObject:inter];
	//[line addLine_interceptionsObject:inter];
	//inter.bus = bus;
	if (inter.bus != bus) {
		NSLog(@"tá errado issae");
	}
	
	
	[context save:&error];
	
	if ([inter.bus isEqual: bus]) {
		NSLog(@"tá errado issae");
	}
	
	return error == nil ? inter : nil;
}

@end
