//
//  CoreDataAndRequestSupervisor.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreDataAndRequestSupervisor.h"
#import "ServerUpdateRequest.h"
#import "Bus_line+Core_Data_Methods.h"
#import "Bus_points+CoreDataMethods.h"
#import "Interception+CoreDataMethods.h"
#import "JsonRequest.h"
#import "StopTime+CoreDataMethods.h"


@interface CoreDataAndRequestSupervisor () <ServerUpdateRequestDelegate,JsonRequestDelegate>

@property (nonatomic, strong) NSMutableArray *jsonsRequests;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) int finishedOperations;
@property (nonatomic) int dueOperations;
@property (nonatomic) int newestVersion;
@property (nonatomic) int requestsFeitas;
@property (nonatomic, strong) NSMutableArray* operations;


@end

@implementation CoreDataAndRequestSupervisor

static  CoreDataAndRequestSupervisor *supervisor;

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
		self.finishedOperations = 0;
		self.requestsFeitas = 0;
		self.operations = [[NSMutableArray alloc] init];
		self.lock = @"lock";
    }
    
    return self;
}

#pragma mark - request methods

-(void)requestBusLines
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSLog(@"%ld",(long)[prefs integerForKey:@"version"]);
    ServerUpdateRequest *serverUpdate = [[ServerUpdateRequest alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
	//If the current version is equal 0 or, if the update wasn`t done since the last 3 days.
//    if(([currentDate timeIntervalSinceDate:[prefs objectForKey:@"last update"]] > 60*60*24*3) || ([prefs integerForKey:@"version"] == 0))
//    {
        [serverUpdate requestServerUpdateWithVersion:[prefs integerForKey:@"version"]
                                        withDelegate:self];
//    }
}

#pragma mark - server update delegate methods

-(void)request:(ServerUpdateRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error!");
}

-(void)request:(ServerUpdateRequest *)request didFinishWithObject:(id)object
{
	NSArray *allJsons = [object objectForKey:@"diff_files"];
	self.dueOperations = [allJsons count];
	self.newestVersion = [[object objectForKey:@"newest_version"] intValue];
	
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
	NSLog(@"lala");
	//Start parsing the json!
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self.requestsFeitas++;
		NSLog(@"requestsFeitas: %d\n", self.requestsFeitas);
		
		BOOL save = NO;
		//Save the bus line with a synchro lock, otherwise it would cause errors.
		@synchronized(self.lock){
			 save = [Bus_line saveBusLineWithDictionary:json];
		}
        if(!save)
        {
            NSLog(@"i deu zica no save");
        }
        else
        {
            NSLog(@"Terminou 1 save.");
			self.finishedOperations++;
			NSLog(@"%d\n",self.finishedOperations);
			if (self.finishedOperations == self.dueOperations) {
				//If our DB is complete, start creating interseptions references:
				NSLog(@"Started creating interseptions references");
				[Bus_line removeBusInterseptionsReferences];
				[Bus_line createBusInterseptionsReferences];
				NSLog(@"Finished creating interseptions references");
				//if everything was succesfully completed, set the version to the newest one on the server.
				[[NSUserDefaults standardUserDefaults] setInteger:self.newestVersion forKey:@"version"];
				self.finishedOperations = 0;
			}
        }
    }];
    [self.operations addObject:operation];
    [self.queue addOperation:operation];
}

#pragma mark - CoreData methods
/** Function that receives a distance and a point and returns all Bus_points on the database(return it async with a delegate), 
	that is at "distance" far from the initial point. It uses the Vincent Formulas to geo box the region.
 @param (CGFloat) distance distance in meters.
 @param (CLLocationCoordinate2D) startingPoint - Point from wich we have to calculate the distance.
*/
-(void) getAllBusPointsAsyncWithinDistance:(CGFloat)distance fromPoint:(CLLocationCoordinate2D)point{
	NSMutableArray* geoBox = [[NSMutableArray alloc] init];
	NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
		//Create the geobox
		for (int i = 0; i < 4; i++) {
			CLLocationCoordinate2D tempPoint = [CoreLocationExtension NewLocationFrom:point atDistanceInMeters:distance alongBearingInDegrees:i*90.0];
			[geoBox addObject:[[CLLocation alloc] initWithLatitude:tempPoint.latitude longitude:tempPoint.longitude]];
		}
		[self.delegate requestdidFinishWithObject:[Bus_points getAllBusStopsWithinGeographicalBox:geoBox]];
	}];
	
	[self.queue addOperation:operation];
}

/** Method that returns(async, as a delegate) the required information to the tree algorithm calculate a route(the lines 
 that are "range" close to the initial point and the lines that are "range" close to the final point.
 @param (CLLocationCoordinate2D)initialPoint - initial point
 @param (CLLocationCoordinate2D)finalPoint - final point
 @param (CGFloat)range -  max distance that the users want to walk
 */
-(void) getRequiredTreeLinesWithInitialPoint:(CLLocationCoordinate2D)initialPoint andFinalPoint:(CLLocationCoordinate2D)finalPoint withRange:(CGFloat)range{
	NSMutableArray* geoBoxInitial = [[NSMutableArray alloc] init];
	NSMutableArray* geoBoxFinal = [[NSMutableArray alloc] init];
	NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
		//Create the geobox
		for (int i = 0; i < 4; i++) {
			CLLocationCoordinate2D tempPoint = [CoreLocationExtension NewLocationFrom:initialPoint atDistanceInMeters:range alongBearingInDegrees:i*90.0];
			[geoBoxInitial addObject:[[CLLocation alloc] initWithLatitude:tempPoint.latitude longitude:tempPoint.longitude]];
		}
		for (int i = 0; i < 4; i++) {
			CLLocationCoordinate2D tempPoint = [CoreLocationExtension NewLocationFrom:finalPoint atDistanceInMeters:range alongBearingInDegrees:i*90.0];
			[geoBoxFinal addObject:[[CLLocation alloc] initWithLatitude:tempPoint.latitude longitude:tempPoint.longitude]];
		}
		NSMutableSet* initial = [[NSMutableSet alloc] init];
		NSMutableSet* final =  [[NSMutableSet alloc] init];

		for (Bus_points* point in [Bus_points getAllBusStopsWithinGeographicalBox:geoBoxInitial]) {
			[initial addObjectsFromArray:[point.onibus_que_passam allObjects]];
		}
		for (Bus_points* point in [Bus_points getAllBusStopsWithinGeographicalBox:geoBoxFinal]) {
			[final addObjectsFromArray:[point.onibus_que_passam allObjects]];
		}
		for (Bus_line* line in final) {
			NSLog(@"%@", line.line_number);
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.treeDelegate requestDataDidFinishWithInitialArray:initial andWithFinal:final];
		});
	}];
	
	[self.queue addOperation:operation];
	
}

-(void)circularUnicamp
{
    Bus_line *bus = [NSEntityDescription insertNewObjectForEntityForName:@"Bus_line"
                                                  inManagedObjectContext:self.context];
    
    bus.full_name = @"Circular 2";
    
    NSMutableDictionary *timeStop  = [[NSMutableDictionary alloc] init];
    [timeStop setObject:bus forKey:@"Bus"];
    
    NSArray *timeStrr = [[NSArray alloc] initWithObjects:
                         
                         @"07:35,08:25,11:05,11:35,12:10,12:45,13:10,13:40,14:10,17:00,17:35",
                         
                         @"07:35,08:26,11:06,11:35,12:10,12:46,13:11,13:41,14:10,17:01,17:36",
                         
                         @"07:37,08:27,11:07,11:37,12:12,12:48,13:13,13:42,14:12,17:02,17:38",
                         
                         @"07:38,08:28,11:08,11:38,12:13,12:50,13:14,13:43,14:13,17:03,17:39",
                         
                         @"07:38,08:30,11:09,11:39,12:16,12:51,13:15,13:44,14:15,17:04,17:40",
                         
                         @"07:39,08:31,11:10,11:39,12:17,12:51,13:16,13:45,14:15,17:04,17:40",
                         
                         @"07:40,08:32,11:10,11:40,12:18,12:52,13:16,13:46,14:16,17:05,17:41",
                         
                         @"07:40,08:33,11:11,11:41,12:19,12:52,13:17,13:47,14:16,17:05,17:42",
                         
                         @"07:41,08:33,11:12,11:42,12:20,12:53,13:18,13:48,14:17,17:06,17:43",
                         
                         @"07:43,08:34,11:13,11:42,12:21,12:54,13:19,13:48,14:17,17:06,17:43",
                         
                         @"07:44,08:34,11:14,11:43,12:22,12:54,13:19,13:49,14:18,17:07,17:44",
                         
                         @"07:45,08:35,11:15,11:44,12:23,12:55,13:20,13:50,14:19,17:07,17:45",
                         
                         @"07:45,08:36,11:15,11:44,12:23,12:56,13:21,13:50,14:19,17:08,17:45",
                         
                         @"07:45,08:37,11:16,11:45,12:24,12:56,13:22,13:51,14:20,17:08,17:46",
                         
                         @"07:46,08:38,11:17,11:46,12:24,12:57,13:23,13:52,14:21,17:09,17:46",
                         
                         @"07:48,08:39,11:18,11:47,12:25,12:57,13:23,13:53,14:22,17:09,17:47",
                         
                         @"07:49,08:40,11:19,11:48,12:25,12:59,13:24,13:54,14:23,17:09,17:48",
                         
                         @"07:50,08:41,11:21,11:50,12:27,13:00,13:25,13:54,14:24,17:10,17:48",
                         
                         @"07:51,08:42,11:21,11:50,12:28,13:01,13:25,13:55,14:25,17:11,17:49",
                         
                         @"07:51,08:43,11:22,11:51,12:29,13:01,13:25,13:56,14:25,17:11,17:50",
                         
                         @"07:52,08:44,11:23,11:52,12:30,13:02,13:26,13:57,14:26,17:12,17:50",
                         
                         @"07:55,08:45,11:24,11:53,12:31,13:03,13:27,13:58,14:27,17:13,17:51",
                         
                         @"07:55,08:45,11:25,11:53,12:32,13:03,13:28,13:59,14:28,17:13,17:52",
                         
                         @"07:56,08:45,11:26,11:54,12:32,13:04,13:28,14:00,14:29,17:14,17:52",
                         
                         @"07:57,08:46,11:26,11:55,12:32,13:04,13:29,14:00,14:29,17:14,17:52",
                         
                         @"07:58,08:47,11:27,11:56,12:33,13:05,13:30,14:01,14:30,17:15,17:53",
                         
                         @"08:00,08:48,11:28,11:57,12:35,13:06,13:31,14:02,14:31,17:16,17:54",
                         
                         @"08:01,08:49,11:29,11:58,12:36,13:07,13:32,14:03,14:32,17:17,17:55",
                         
                         @"08:01,08:50,11:30,11:58,12:37,13:08,13:33,14:04,14:34,17:17,17:56",
                         
                         nil];

    for (NSString *string in timeStrr) {
    
        NSMutableArray *times = [self stopTimesArrayWith: string];
    
        [timeStop setObject:times forKey:@"times"];
    
        //Alterar lat e lng de acordo com o ponto
        NSNumber *lat = [NSNumber numberWithDouble:-22.816603];
        NSNumber *lng = [NSNumber numberWithDouble:-47.07293];
    
        [timeStop setObject:lat forKey:@"lat"];
        [timeStop setObject:lng forKey:@"lg"];
    }
    
    BOOL save = [StopTime createBusStopTimeWithDictionary:timeStop];
    
        
    if(!save)
    {
        //TODO
    }
}

-(NSMutableArray*)stopTimesArrayWith: (NSString *) timeStr
{
    NSMutableArray *times = [[NSMutableArray alloc] init];
    
    NSArray *array = [[NSArray alloc] init];
    
    array = [timeStr componentsSeparatedByString:@","];
    
    for(NSString *time in array)
    {
        NSArray *minHours = [[NSArray alloc] init];
        minHours = [time componentsSeparatedByString:@":"];
        [times addObject:[self returnTimeInSeconds:minHours]];
    }
    
    
    return times;
}

-(NSNumber*)returnTimeInSeconds:(NSArray*)time
{
    
    NSTimeInterval seconds = ([time[0] doubleValue]*60*60) + ([time[1] doubleValue]*60);
    
    NSNumber *total = [NSNumber numberWithDouble:seconds];
    
    return total;
}



@end
