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
	if (![line.full_name isEqualToString:bus.full_name]) {
		NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
		
		NSError* error = nil;
		
		//Create a new bus_point
		Interception * inter = [NSEntityDescription insertNewObjectForEntityForName:@"Interception"
															 inManagedObjectContext:context];
		inter.bus_alvo = bus;
		//[inter setValue:bus forKey:@"bus"];
		inter.stop = stop;
		inter.bus_inicial = line;
		
		//[stop addInterceptionsObject:inter];
		//[line addLine_interceptionsObject:inter];
		//inter.bus = bus;
		if (inter.bus_alvo != bus) {
			NSLog(@"tá errado issae");
		}
		if (inter.bus_inicial != line) {
			NSLog(@"tá errado issae");
		}

		
		
		[context save:&error];
				
		return error == nil ? inter : nil;
	}
	return nil;
}

//Create a interception with 2 bus lines and a point.
+(void) createInterceptionForBus:(Bus_line*)line withSetOfInterceptions:(NSArray*)buses withPoint:(NSArray*)stop{
	int i = 0;
	for (Bus_line* bus in buses) {
		Interception* inter = [Interception createInterceptionForBus:line withInterceptionBus:bus withPoint:stop[i]];
		NSLog(@"inter alvo: %@ inicial: %@", inter.bus_alvo.line_number, inter.bus_inicial.line_number);
		i++;
	}
}


+(NSArray*) getAllInterceptionsForBus:(Bus_line*)bus{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
    
	//Check if it already exists:
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Interception" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"ANY bus_inicial.web_number == %@", bus.web_number];
	[request setReturnsObjectsAsFaults:NO];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return array;

}

@end
