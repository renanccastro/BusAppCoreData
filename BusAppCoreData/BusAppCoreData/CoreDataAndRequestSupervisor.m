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

//get bus stop with lat and lng
-(Bus_points*) getBusPointWithLatitude:(double)lat withLongitude:(double)lng{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf",lat, lng];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	if (error){
		NSLog(@"error getting bus");
	}
	
	return [array firstObject];
}

//Return all stops from one bus line
-(NSArray*) getBusLineStops:(Bus_line*)bus_line{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  
											  entityForName:@"Bus_points" inManagedObjectContext:self.context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"ANY onibus_que_passam.web_number == %d", [bus_line.web_number integerValue]];
	[request setPredicate:predicate];
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
	NSLog(@"%@",[[array firstObject] class]);
	if (error){
		NSLog(@"error getting bus");
	}
	return array;
}

-(Polyline_points*) getPolyLinePointsWithLatitude:(double)lat andWithLongitude:(double)lng
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
                                                         inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lat == %lf AND lng == %lf", lat, lng];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    if(error)
    {
        NSLog(@"i deu zica");
    }
    
    return [array firstObject];
}

-(NSArray*) getBusLineTrajectory:(Bus_line*)bus withTurn:(NSString*)turn
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Polyline_points"
                                                         inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    turn = [turn stringByAppendingString:@".web_number"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %@ == %d", turn, [bus.web_number integerValue]];
    [request setPredicate:predicate];
    
	NSError *error;
	NSArray *array = [self.context executeFetchRequest:request error:&error];
    if(error)
    {
        NSLog(@"ha deu zica nessa trajetoria ai");
    }
    
    return array;
}

@end
