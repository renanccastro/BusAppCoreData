//
//  Polyline_points+CoreDataMethods.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Polyline_points+CoreDataMethods.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Bus_line.h"

@implementation Polyline_points (CoreDataMethods)


/** Method that returns a unique polyline_point with given latitude and longitude
 @param (double)lat - latitude
 @param (double)lng - longitude
 @return (Polyline_points*) - polyline_point that matches the parameters.
 */
+(Polyline_points*) getPolyLinePointsWithLatitude:(double)lat andWithLongitude:(double)lng
{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
                                                         inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf", lat, lng];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
	
    if(error)
    {
        NSLog(@"i deu zica");
    }
    
    return [array firstObject];
}


/** Method that returns an array of polyline_point that belongs to a bus_line
 @param (Bus_line*)bus - bus line that owns the points
 @param (NSString*)turn - string that describes the type of polyline, "linha_ida" ou "linha_volta".
 @return (NSArray*) - Array of polyline_point that matches the parameters.
 */
+(NSArray*) getBusLineTrajectory:(Bus_line*)bus withTurn:(NSString*)turn
{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
                                                         inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    turn = [turn stringByAppendingString:@".web_number"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %d", turn, [bus.web_number integerValue]];
    [request setPredicate:predicate];
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order"
																 ascending:YES];
	[request setSortDescriptors:@[descriptor]];
    
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
    if(error)
    {
        NSLog(@"ha deu zica nessa trajetoria ai");
    }
    
    return array;
}

/** Method that creates a polyline point("to") with given parameters.
 @param (Bus_line*)bus - bus line that owns the points
 @param (double)lat - latitude
 @param (double)lng - longitude
 @param (int)order - order of the given point in the route of the bus.
 @return (Polyline_points*) - New polyline_point that matches the parameters.
 */
+(Polyline_points*) createPolylinePointIdaWithBus:(Bus_line*)bus withLat:(double)lat andLng:(double)lng withOrder:(int)order{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSNumber * lat_number = [NSNumber numberWithDouble:lat];
	NSNumber * lng_number = [NSNumber numberWithDouble:lng];
	NSError* error = nil;
	
	Polyline_points* point = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
														   inManagedObjectContext:context];
	
	point.lat = lat_number;
	point.lng = lng_number;
	point.linha_ida = bus;
	point.order = [[NSNumber alloc] initWithInt:order];
	[bus addPolyline_idaObject:point];
	
	[context save:&error];
	
	return error == nil ? point : nil;
}

/** Method that creates a polyline point("from") with given parameters.
 @param (Bus_line*)bus - bus line that owns the points
 @param (double)lat - latitude
 @param (double)lng - longitude
 @param (int)order - order of the given point in the route of the bus.
 @return (Polyline_points*) - New polyline_point that matches the parameters.
 */
+(Polyline_points*) createPolylinePointVoltaWithBus:(Bus_line*)bus withLat:(double)lat andLng:(double)lng withOrder:(int)order
{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
	NSNumber * lat_number = [NSNumber numberWithDouble:lat];
	NSNumber * lng_number = [NSNumber numberWithDouble:lng];
	NSError* error = nil;
	
	Polyline_points* point  = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
															inManagedObjectContext:context];
	
	point.lat = lat_number;
	point.lng = lng_number;
	point.order = [[NSNumber alloc] initWithInt:order];
	point.linha_volta = bus;
	[bus addPolyline_voltaObject:point];
	
	[context save:&error];
	
	return error == nil ? point : nil;
}

-(void) removePointFromDatabase{
	[[[CoreDataAndRequestSupervisor startSupervisor] context] deleteObject:self];
}




@end
