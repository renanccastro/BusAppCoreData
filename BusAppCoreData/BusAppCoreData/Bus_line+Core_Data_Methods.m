//
//  Bus_line+Core_Data_Methods.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Bus_line+Core_Data_Methods.h"
#import "Bus_points+CoreDataMethods.h"
#import "Polyline_points+CoreDataMethods.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Interception+CoreDataMethods.h"
#import "Bus_points+CoreDataMethods.h"

@implementation Bus_line (Core_Data_Methods)

+(BOOL) saveBusLineWithDictionary:(NSDictionary*)parsedData
{
	CoreDataAndRequestSupervisor *supervisor = [CoreDataAndRequestSupervisor startSupervisor];
	Bus_line *bus = [Bus_line getBusWithWebCode:[parsedData[@"web_code"] intValue]];
    
	//if there wasn't a bus with the same code:
	if (bus == nil)
    {
		//Create a new bus_line with name new_line
		Bus_line* new_line = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Bus_line"
                              inManagedObjectContext:supervisor.context];
        
		NSString * full_name = [[parsedData[@"name"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
		new_line.full_name = full_name;
		
		new_line.line_number = [Bus_line getBusNumberFromFullName:new_line.full_name];
		new_line.web_number = [[NSNumber alloc ] initWithInt:[parsedData[@"web_code"] integerValue]];
        
        [new_line createReferencesWithLineWithDictionary:parsedData];
	}
	//IF THERE WAS ALREADY A BUS IN THE DATABASE
	else{
		NSString * full_name = [[parsedData[@"name"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@"\r" withString:@" "];

		bus.full_name = full_name;
		
		//Getting all numbers in the string.
		bus.line_number = [Bus_line getBusNumberFromFullName:bus.full_name];
		
		bus.web_number = [[NSNumber alloc ] initWithInt:[parsedData[@"web_code"] integerValue]];
        
        [bus removeReferencesOfBusLine];
        
        [bus createReferencesWithLineWithDictionary:parsedData];
        
	}
	NSError * saveError;
	//[supervisor.context save:&saveError];
	
	NSLog(@"Save error %@",[saveError localizedDescription]);
	
	return saveError ? NO : YES;
	
	
	
}

-(void)removeReferencesOfBusLine
{
    for(Bus_points *points in [Bus_points getBusLineStops:self])
    {
        [points removeOnibus_que_passamObject:self];
    }
    
    for(Polyline_points *points in [Polyline_points getBusLineTrajectory:self
                                                                withTurn:@"linha_ida"])
    {
        [points removePointFromDatabase];
		[self removePolyline_idaObject:points];
    }
    
    for(Polyline_points *points in [Polyline_points getBusLineTrajectory:self
                                                                withTurn:@"linha_volta"])
    {
        [points removePointFromDatabase];
		[self removePolyline_voltaObject:points];

    }
}

-(void)createReferencesWithLineWithDictionary:(NSDictionary*)parsedData
{
    for(NSDictionary *point in parsedData[@"pontos"])
    {
        [self addStopsObject:[Bus_points createBusPointFromBusLine:self
                                                           withLat:[point[@"lat"] doubleValue]
												  andLong:[point[@"lng"] doubleValue]]];;
    }
	
    int i = 0;
    for(NSDictionary *polyLine in parsedData[@"polyline_ida"])
    {
        Polyline_points* point = [Polyline_points createPolylinePointIdaWithBus:self
																		 withLat:[polyLine[@"lat"] doubleValue]
																		 andLng:[polyLine[@"lng"] doubleValue] withOrder:i];
		i++;
		[self addPolyline_idaObject:point];
    }
    i=0;
    for(NSDictionary *polyLine in parsedData[@"polyline_volta"])
    {
        [self addPolyline_voltaObject:[Polyline_points createPolylinePointVoltaWithBus:self
                                                                               withLat:[polyLine[@"lat"] doubleValue]
                                                                                andLng:[polyLine[@"lng"] doubleValue] withOrder:i]];
		i++;
    }
}

//get bus from database with identifider(web_code)
+(Bus_line*) getBusWithWebCode:(int)web_code
{
    NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;

    
	//Check if it already exists:
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_line" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"web_number == %d", web_code];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return [array firstObject];
}

+(NSNumber*) getBusNumberFromFullName:(NSString*)name{
	//Getting all numbers in the string.
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:	NSRegularExpressionCaseInsensitive error:nil];
	NSTextCheckingResult *match = [regex firstMatchInString:name
													options:0
													  range:NSMakeRange(0, [name length])];
	NSRange range = NSMakeRange([match range].location, 3);
	
	return [[NSNumber alloc] initWithInt:[[name substringWithRange:range] intValue]];
    
}

+(NSArray*)getAllBus{
	NSManagedObjectContext* context = [CoreDataAndRequestSupervisor startSupervisor].context;
	
    
	//Check if it already exists:
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
								entityForName:@"Bus_line" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSError *error;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return array;
}


+(BOOL) createBusInterseptionsReferences{
	NSArray* buses = [Bus_line getAllBus];
	NSMutableArray* set = [[NSMutableArray alloc] init];
	NSMutableArray* stops = [[NSMutableArray alloc] init];
	for (Bus_line* line in buses) {
		for (Bus_points* stop in line.stops) {
			for (Bus_line* bus in stop.onibus_que_passam) {
				if (![bus.web_number isEqualToNumber:line.web_number]){
					if (![set containsObject:bus] && ![bus.web_number isEqualToNumber:line.web_number ]) {
						[stops addObject:stop];
						[set addObject:bus];
						NSLog(@"Creating Interception for bus: %@ with bus: %@",bus.line_number, line.line_number);
					}
				}
			}
		}
		[Interception createInterceptionForBus:line withSetOfInterceptions:set withPoint:stops];
		[set removeAllObjects];
		[stops removeAllObjects];

	}
	
	
	
	return YES;
}

+(void) removeBusInterseptionsReferences{
	NSArray* buses = [Bus_line getAllBus];
	for (Bus_line* line in buses) {
		[line removeLine_interceptions:line.line_interceptions];
	}
}


@end
