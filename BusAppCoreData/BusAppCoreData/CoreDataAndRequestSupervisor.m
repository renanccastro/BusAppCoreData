//
//  CoreDataAndRequestSupervisor.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreDataAndRequestSupervisor.h"
#import "Bus_line.h"

@interface CoreDataAndRequestSupervisor ()

@property (nonatomic, strong) UIManagedDocument * document;
@property (nonatomic, strong) NSURLRequest *serverFirstRequest;
@property (nonatomic, strong) NSArray *jsonsRequests;

@end

@implementation CoreDataAndRequestSupervisor

-(void)requestBusLinesWithDelegate:(id<CoreDataAndRequestSupervisorDelegate>)delegate
{
    [self setDelegate:delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if(![prefs integerForKey:@"version"])
    {
        [prefs setInteger:0 forKey:@"version"];
    }
    
    
    
    
}

-(BOOL) saveBusLineWithJsonString:(NSData*)jsonData{
	NSError *jsonParsingError = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
	if (jsonParsingError)
		return NO;
	
	
	Bus_line *bus = [self getBusWithWebCode:[dictionary[@"web_code"] integerValue]];
	
	//if there wasn't a bus with the same code:
	if (bus == nil){
		//Create a new bus_line
		Bus_line* line = [NSEntityDescription
						  
						  insertNewObjectForEntityForName:@"Bus_line"
						  
						  inManagedObjectContext:self.context];
		line.full_name = dictionary[@"name"];
		
		//Getting all numbers in the string.
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:NSRegularExpressionCaseInsensitive error:nil];
		NSArray *matches = [regex matchesInString:dictionary[@"name"]
										  options:0
											range:NSMakeRange(0, [dictionary[@"name"] length])];
		line.line_number = [NSNumber numberWithInt:[[matches lastObject] integerValue] ];
		line.web_number = dictionary[@"web_code"];
		
//		NSMutableArray* stops = [[NSMutableArray alloc] init];
#warning TODO
		
		
	}
	//if there already has
	else{
		bus.full_name = dictionary[@"name"];
		bus.web_number = dictionary[@"web_code"];
		
	}
	return YES;
}

//get bus from database with identifider(web_code)
-(Bus_line*) getBusWithWebCode:(int)web_code{
	//Check if it already exists:
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_line" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"web_number == %@", web_code];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return [array lastObject];
}

//get bus stop with lat and lng
-(Bus_points*) getBusPointWithLatitude:(double)lat withLongitude:(double)lng{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"lat == %@ AND lng == %@", lat, lng];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	
	return [array lastObject];
}

//Return all stops from one bus line
-(NSArray*) getBusLineStops:(Bus_line*)bus_line{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"onibus_que_passam CONTAINS %@", bus_line];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return array;
}



@end
