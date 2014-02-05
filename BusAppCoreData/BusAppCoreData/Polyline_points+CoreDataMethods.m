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


//Get Polyline points unique
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


//Get all points in the polyline for bus with TURN->ida ou volta
+(NSArray*) getBusLineTrajectory:(Bus_line*)bus withTurn:(NSString*)turn
{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
                                                         inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    turn = [turn stringByAppendingString:@".web_number"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY linha_ida.web_number == %d", [bus.web_number integerValue]];
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
