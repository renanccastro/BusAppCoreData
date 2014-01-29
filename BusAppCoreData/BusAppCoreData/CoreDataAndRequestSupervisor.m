//
//  CoreDataAndRequestSupervisor.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreDataAndRequestSupervisor.h"
#import "ServerUpdateRequest.h"
#import "Bus_line.h"
#import "Bus_points.h"
#import "JsonRequest.h"
#import "Polyline_points.h"

@interface CoreDataAndRequestSupervisor () <ServerUpdateRequestDelegate,JsonRequestDelegate>

@property (nonatomic, strong) NSMutableArray *jsonsRequests;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation CoreDataAndRequestSupervisor

static CoreDataAndRequestSupervisor *supervisor;

#pragma mark -  singleton methods

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [CoreDataAndRequestSupervisor startSupervisor];
}

+(CoreDataAndRequestSupervisor*) startSupervisor
{
    if(!supervisor)
    {
        supervisor = [[super allocWithZone:nil]  init];
    }
    
    return supervisor;
}

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.jsonsRequests = [[NSMutableArray alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

#pragma mark - request methods

-(void)requestBusLines
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    ServerUpdateRequest *serverUpdate = [[ServerUpdateRequest alloc] init];
    
        if(![prefs integerForKey:@"version"])
        {
            [prefs setInteger:0 forKey:@"version"];
        }
    
        [serverUpdate requestServerUpdateWithVersion:[prefs integerForKey:@"version"]
                                        withDelegate:self];
        
}

//-(BOOL)needUpdateSince:(NSDate*)currentDate
//{
//    TODO
//}

#pragma mark - server update delegate methods

-(void)request:(ServerUpdateRequest *)request didFailWithError:(NSError *)error
{
    //TODO
}

-(void)request:(ServerUpdateRequest *)request didFinishWithObject:(id)object
{
        //Update the current version of the server
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setInteger:[[object objectForKey:@"newest_version"] integerValue] forKey:@"version"];
    
        NSArray *allJsons = [object objectForKey:@"diff_files"];
        
        //make a request for the jsons with the bus lines points
        for(NSString *busLine in allJsons)
        {
            JsonRequest *jsonRequest = [[JsonRequest alloc] init];
            [jsonRequest requestJsonWithName:busLine withdelegate:self];
            [self.jsonsRequests addObject:jsonRequest];
        }
    
}

#pragma mark - json request delegate  methods

-(void)request:(JsonRequest *)request didFailInGetJson:(NSError *)error
{
    //TODO
}

-(void)request:(JsonRequest *)request didFinishWithJson:(id)json
{
    //Core Data Methods Here
}

#pragma mark - core data methods

//-(BOOL) saveBusLineWithJsonData:(NSData*)jsonData{
//	NSError *jsonParsingError = nil;
//	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
//	
//	if (jsonParsingError)
//		return NO;
//	
//	Bus_line *bus = [self getBusWithWebCode:[dictionary[@"web_code"] intValue]];
//
//	//if there wasn't a bus with the same code:
//	if (bus == nil)
//    {
//		//Create a new bus_line with name new_line
//		Bus_line* new_line = [NSEntityDescription
//                              insertNewObjectForEntityForName:@"Bus_line"
//                              inManagedObjectContext:self.context];
//        
//		new_line.full_name = dictionary[@"name"];
//		
//		new_line.line_number = [self getBusNumberFromFullName:new_line.full_name];
//		new_line.web_number = [[NSNumber alloc ] initWithInt:[dictionary[@"web_code"] integerValue]];
//		NSLog(@"%@",new_line.web_number);
//		Bus_points* bus_stop;
//        Polyline_points *ida;
//        Polyline_points *volta;
//        
//        for(NSDictionary* polyLinePoint in dictionary[@"polyline_ida"])
//        {
//            if(!(ida = [self getPolyLinePointsWithLatitude:[polyLinePoint[@"lat"] doubleValue]
//                                          andWithLongitude:[polyLinePoint[@"lng"] doubleValue]]))
//            {
//                 Polyline_points *trajectory = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
//                                                                             inManagedObjectContext:self.context];
//                
//                trajectory.lat = polyLinePoint[@"lat"];
//                trajectory.lng = polyLinePoint[@"lng"];
//                [trajectory addLinhas_idaObject:new_line];
//                [new_line addPolyline_idaObject:trajectory];
//            }
//            else
//            {
//                [ida addLinhas_idaObject:new_line];
//                [new_line addPolyline_idaObject:ida];
//            }
//        }
//        
//        if(dictionary[@"polyline_volta"])
//        {
//            for(NSDictionary *polyLinePoint in dictionary[@"polyline"])
//            {
//                if(!(volta = [self getPolyLinePointsWithLatitude:[polyLinePoint[@"lat"] doubleValue]
//                                                andWithLongitude:[polyLinePoint[@"lng"] doubleValue]]))
//                {
//                    Polyline_points *trajectory = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
//                                                                                inManagedObjectContext:self.context];
//                    
//                    
//                    trajectory.lat = polyLinePoint[@"lat"];
//                    trajectory.lng = polyLinePoint[@"lng"];
//                    [trajectory addLinhas_voltaObject:new_line];
//                    [new_line addPolyline_voltaObject:trajectory];
//                }
//                else
//                {
//                    [volta addLinhas_voltaObject:new_line];
//                    [new_line addPolyline_voltaObject:volta];
//                }
//            }
//        }
//        else
//        {
//            [new_line addPolyline_volta:new_line.polyline_ida];
//            
//            for(Polyline_points *trajectoryPoint in [self getBusLineTrajectory:new_line
//                                                                      withTurn:@"linhas_ida"])
//            {
//                [trajectoryPoint addLinhas_voltaObject:new_line];
//            }
//        }
//		
//		for (NSDictionary* point in dictionary[@"pontos"]) {
//			//Set the bus_stop variable to the database stop point
//			// IF THERE ISN`T A BUS STOP WITH THIS LAT AND LONG, CREATE A NEW ONE
//			if (!(bus_stop = [self getBusPointWithLatitude:[point[@"lat"] doubleValue]
//                                             withLongitude:[point[@"lng"] doubleValue]]))
//            {
//				//Create a new bus_point
//				Bus_points* stop = [NSEntityDescription insertNewObjectForEntityForName:@"Bus_points"
//                                                                 inManagedObjectContext:self.context];
//				stop.lat = point[@"lat"];
//				stop.lng = point[@"lng"];
//				[stop addOnibus_que_passamObject:new_line];
//				[new_line addStopsObject:stop];
//			}
//			else{
//				[bus_stop addOnibus_que_passamObject:new_line];
//				[new_line addStopsObject:bus_stop];
//			}
//
//		}
//		
//	}
//	//IF THERE WAS ALREADY A BUS IN THE DATABASE
//	else{
//		bus.full_name = dictionary[@"name"];
//		
//		//Getting all numbers in the string.
//		bus.line_number = [self getBusNumberFromFullName:bus.full_name];
//		
//		bus.web_number = [[NSNumber alloc ] initWithInt:[dictionary[@"web_code"] integerValue]];
//
//		for (Bus_points* stops in [self getBusLineStops:bus]) {
//			[stops removeOnibus_que_passamObject:bus];
//			NSLog(@"%@ %@",stops.lat,stops.lng);
//		}
//        
//        for(Polyline_points *trajectoryPoint in [self getBusLineTrajectory:bus
//                                                                  withTurn:@"linhas_ida"])
//        {
//            [trajectoryPoint removeLinhas_idaObject:bus];
//        }
//        
//        for(Polyline_points *trajectoryPoint in [self getBusLineTrajectory:bus
//                                                                  withTurn:@"linhas_volta"])
//        {
//            [trajectoryPoint removeLinhas_voltaObject:bus];
//        }
//
//        
//		Bus_points* bus_stop = nil;
//		for (NSDictionary* point in dictionary[@"pontos"]) {
//			bus_stop = [self getBusPointWithLatitude:[point[@"lat"] doubleValue] withLongitude:[point[@"lng"] doubleValue]];
//			NSLog(@"%f, %f",[point[@"lat"] doubleValue] ,[point[@"lng"] doubleValue] );
//			//Set the bus_stop variable to the database stop point
//			// IF THERE ISN`T A BUS STOP WITH THIS LAT AND LONG, CREATE A NEW ONE
//			if (bus_stop == nil) {
//				//Create a new bus_point
//				Bus_points* stop = [NSEntityDescription insertNewObjectForEntityForName:@"Bus_points"
//                                                                 inManagedObjectContext:self.context];
//				stop.lat = point[@"lat"];
//				stop.lng = point[@"lng"];
//				[stop addOnibus_que_passamObject:bus];
//				[bus addStopsObject:stop];
//			}
//			else
//            {
//				[bus_stop addOnibus_que_passamObject:bus];
//				[bus addStopsObject:bus_stop];
//			}
//			
//		}
//        
//        Polyline_points *ida;
//        Polyline_points *volta;
//        
//        for(NSDictionary* polyLinePoint in dictionary[@"polyline_ida"])
//        {
//            if(!(ida = [self getPolyLinePointsWithLatitude:[polyLinePoint[@"lat"] doubleValue]
//                                          andWithLongitude:[polyLinePoint[@"lng"] doubleValue]]))
//            {
//                Polyline_points *trajectory = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
//                                                                            inManagedObjectContext:self.context];
//                
//                trajectory.lat = polyLinePoint[@"lat"];
//                trajectory.lng = polyLinePoint[@"lng"];
//                [trajectory addLinhas_idaObject:bus];
//                [bus addPolyline_idaObject:trajectory];
//            }
//            else
//            {
//                [ida addLinhas_idaObject:bus];
//                [bus addPolyline_idaObject:ida];
//            }
//        }
//        
//        if(dictionary[@"polyline_volta"])
//        {
//            for(NSDictionary *polyLinePoint in dictionary[@"polyline"])
//            {
//                if(!(volta = [self getPolyLinePointsWithLatitude:[polyLinePoint[@"lat"] doubleValue]
//                                                andWithLongitude:[polyLinePoint[@"lng"] doubleValue]]))
//                {
//                    Polyline_points *trajectory = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline_points"
//                                                                                inManagedObjectContext:self.context];
//                    
//                    
//                    trajectory.lat = polyLinePoint[@"lat"];
//                    trajectory.lng = polyLinePoint[@"lng"];
//                    [trajectory addLinhas_voltaObject:bus];
//                    [bus addPolyline_voltaObject:trajectory];
//                }
//                else
//                {
//                    [volta addLinhas_voltaObject:bus];
//                    [bus addPolyline_voltaObject:volta];
//                }
//            }
//        }
//        else
//        {
//            [bus addPolyline_volta:bus.polyline_ida];
//            
//            for(Polyline_points *trajectoryPoint in [self getBusLineTrajectory:bus
//                                                                      withTurn:@"linhas_ida"])
//            {
//                [trajectoryPoint addLinhas_voltaObject:bus];
//            }
//        }
//
//	}
//	NSError * saveError;
//	[self.context save:&saveError];
//		
//#warning TODO
//		
//	
//	return saveError ? NO : YES;
//}


//get bus from database with identifider(web_code)


-(Bus_line*) getBusWithWebCode:(int)web_code{
	//Check if it already exists:
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_line" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"web_number == %d", web_code];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	return [array firstObject];
}


////get bus stop with lat and lng
//-(Bus_points*) getBusPointWithLatitude:(double)lat withLongitude:(double)lng{
//	NSEntityDescription *entityDescription = [NSEntityDescription
//											  
//											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
//	
//	NSFetchRequest *request = [[NSFetchRequest alloc] init];
//	[request setEntity:entityDescription];
//	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf",lat, lng];
//	[request setPredicate:predicate];
//	NSError *error;
//	NSArray *array = [self.context executeFetchRequest:request error:&error];
//	if (error){
//		NSLog(@"error getting bus");
//	}
//	
//	return [array firstObject];
//}

////Return all stops from one bus line
//-(NSArray*) getBusLineStops:(Bus_line*)bus_line{
//	NSEntityDescription *entityDescription = [NSEntityDescription
//											  
//											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
//	
//	NSFetchRequest *request = [[NSFetchRequest alloc] init];
//	[request setEntity:entityDescription];
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:
//							  @"ANY onibus_que_passam.web_number == %d", [bus_line.web_number integerValue]];
//	[request setPredicate:predicate];
//	NSError *error;
//	NSArray *array = [self.context executeFetchRequest:request error:&error];
//	NSLog(@"%@",[[array firstObject] class]);
//	if (error){
//		NSLog(@"error getting bus");
//	}
//	return array;
//}

-(NSNumber*) getBusNumberFromFullName:(NSString*)name{
	//Getting all numbers in the string.
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:	NSRegularExpressionCaseInsensitive error:nil];
	NSTextCheckingResult *match = [regex firstMatchInString:name
													options:0
													  range:NSMakeRange(0, [name length])];
	NSRange range = NSMakeRange([match range].location, 3);
	
	return [[NSNumber alloc] initWithInt:[[name substringWithRange:range] integerValue]];

}

//-(Polyline_points*) getPolyLinePointsWithLatitude:(double)lat andWithLongitude:(double)lng
//{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
//                                                         inManagedObjectContext:self.context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf", lat, lng];
//    [request setPredicate:predicate];
//    
//    NSError *error = nil;
//    NSArray *array = [self.context executeFetchRequest:request error:&error];
//    if(error)
//    {
//        NSLog(@"i deu zica");
//    }
//    
//    return [array firstObject];
//}

//-(NSArray*) getBusLineTrajectory:(Bus_line*)bus withTurn:(NSString*)turn
//{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
//                                                         inManagedObjectContext:self.context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    
//    turn = [turn stringByAppendingString:@".web_number"];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %@ == %d", turn, [bus.web_number integerValue]];
//    [request setPredicate:predicate];
//    
//	NSError *error;
//	NSArray *array = [self.context executeFetchRequest:request error:&error];
//    if(error)
//    {
//        NSLog(@"ha deu zica nessa trajetoria ai");
//    }
//    
//    return array;
//}

//-(BOOL) removeReferencesFromAllStopsOfBus:(Bus_line* bus){
//	
//}

@end
