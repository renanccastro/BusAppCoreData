//
//  Bus_line+Core_Data_Methods.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Bus_line+Core_Data_Methods.h"
#import "Bus_points.h"
#import "Polyline_points.h"
#import "CoreDataAndRequestSupervisor.h"

@implementation Bus_line (Core_Data_Methods)

-(BOOL) saveBusLineWithDictionary:(NSDictionary*)parsedData
{
	CoreDataAndRequestSupervisor *supervisor = [CoreDataAndRequestSupervisor startSupervisor];
	Bus_line *bus = [self getBusWithWebCode:[parsedData[@"web_code"] intValue]];
    
	//if there wasn't a bus with the same code:
	if (bus == nil)
    {
		//Create a new bus_line with name new_line
		Bus_line* new_line = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Bus_line"
                              inManagedObjectContext:supervisor.context];
        
		new_line.full_name = parsedData[@"name"];
		
		new_line.line_number = [self getBusNumberFromFullName:new_line.full_name];
		new_line.web_number = [[NSNumber alloc ] initWithInt:[parsedData[@"web_code"] integerValue]];
		
	}
	//IF THERE WAS ALREADY A BUS IN THE DATABASE
	else{
		bus.full_name = parsedData[@"name"];
		
		//Getting all numbers in the string.
		bus.line_number = [self getBusNumberFromFullName:bus.full_name];
		
		bus.web_number = [[NSNumber alloc ] initWithInt:[parsedData[@"web_code"] integerValue]];
        
	}
	NSError * saveError;
	[supervisor.context save:&saveError];
    
#warning TODO
    
	
	return saveError ? NO : YES;
}

-(NSNumber*) getBusNumberFromFullName:(NSString*)name{
	//Getting all numbers in the string.
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:	NSRegularExpressionCaseInsensitive error:nil];
	NSTextCheckingResult *match = [regex firstMatchInString:name
													options:0
													  range:NSMakeRange(0, [name length])];
	NSRange range = NSMakeRange([match range].location, 3);
	
	return [[NSNumber alloc] initWithInt:[[name substringWithRange:range] integerValue]];
    
}


@end
