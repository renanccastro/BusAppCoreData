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
    if(([currentDate timeIntervalSinceDate:[prefs objectForKey:@"last update"]] > 60*60*24*3) || ([prefs integerForKey:@"version"] == 0))
    {
        [serverUpdate requestServerUpdateWithVersion:[prefs integerForKey:@"version"]
                                        withDelegate:self];
    }
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
    NSNumber *webNumber = [NSNumber numberWithInt:-2];
    bus.web_number = webNumber;
    
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
    
        NSMutableArray *times = [self stopTimesArray: string];
    
    NSNumber *lat = [NSNumber numberWithDouble:-22.816603];
    NSNumber *lng = [NSNumber numberWithDouble:-47.072930];
    
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
    
    Bus_line *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Bus_line"
                                                      inManagedObjectContext:self.context];
    
    newLine.full_name = @"Circular 1";
    webNumber = [NSNumber numberWithInt:-1];
    newLine.web_number = webNumber;
    
    [timeStop setObject:newLine forKey:@"Bus"];
    
    NSString *timeStr = @"6:43,7:38,8:6,8:19,8:41,8:49,9:16,9:46,10:2,10:15,10:31,10:47,11:3,11:16,11:31,11:47,12:4,12:20,12:30,12:46,13:1,13:15,13:31,13:39,14:0,14:18,14:29,14:46,15:16,15:31,15:45,16:17,16:31,16:40,17:6,17:29,17:37,18:10,19:11";
    NSMutableArray *times = [self stopTimesArray:timeStr];
    
    [timeStop setObject:times forKey:@"times"];
    
    NSNumber *lat = [NSNumber numberWithDouble:-22.816603];
    NSNumber *lng = [NSNumber numberWithDouble:-47.072930];
    
    [timeStop setObject:lat forKey:@"lat"];
    [timeStop setObject:lng forKey:@"lg"];
    
    save = [StopTime createBusStopTimeWithDictionary:timeStop];

    
//    timeStr = [NSString stringWithFormat:@"6:30,7:25,7:50,8:00,8:25,8:35,9:00,9:30,9:45,10:00,10:15,10:30,10:45,11:00,11:15,11:30,11:45,12:00,12:15,12:30,12:45,13:00,13:15,13:25,13:45,14:0,14:15,14:30,15:0,15:15,15:30,16:0,16:15,16:25,16:50,17:15,17:20,18:0,19:0"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:31,7:26,7:51,8:01,8:26,8:36,9:01,9:31,9:46,10:00,10:16,10:30,10:46,11:00,11:16,11:30,11:46,12:02,12:15,12:31,12:46,13:01,13:15,13:25,13:45,14:02,14:15,14:30,15:00,15:15,15:30,16:01,16:15,16:26,16:51,17:15,17:21,18:01,19:01"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//
//    timeStr = [NSString stringWithFormat:@"6:32,7:27,7:52,8:03,8:27,8:37,9:03,9:33,9:47,10:03,10:17,10:32,10:48,11:02,11:18,11:31,11:48,12:04,12:16,12:33,12:47,13:02,13:16,13:27,13:47,14:03,14:17,14:32,15:02,15:17,15:32,16:03,16:16,16:27,16:52,17:17,17:23,18:02,19:02"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:32,7:27,7:53,8:04,8:28,8:38,9:04,9:34,9:49,10:04,10:18,10:34,10:49,11:03,11:19,11:32,11:50,12:05,12:17,12:34,12:48,13:03,13:17,13:27,13:48,14:05,14:18,14:33,15:02,15:18,15:33,16:05,16:17,16:28,16:53,17:18,17:24,18:02,19:02"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:33,7:28,7:54,8:05,8:29,8:39,9:05,9:35,9:50,10:04,10:19,10:35,10:50,11:04,11:21,11:34,11:52,12:06,12:18,12:35,12:49,13:04,13:18,13:28,13:49,14:06,14:19,14:34,15:03,15:19,15:34,16:06,16:18,16:29,16:54,17:19,17:25,18:03,19:03"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:34,7:29,7:56,8:06,8:30,8:40,9:06,9:35,9:52,10:05,10:20,10:36,10:51,11:05,11:22,11:35,11:53,12:08,12:19,12:37,12:49,13:05,13:19,13:29,13:50,14:07,14:20,14:34,15:05,15:21,15:34,16:07,16:20,16:30,16:55,17:20,17:26,18:04,19:04"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//
//    timeStr = [NSString stringWithFormat:@"6:34,7:29,7:58,8:08,8:31,8:41,9:06,9:36,9:53,10:05,10:20,10:37,10:51,11:06,11:22,11:36,11:54,12:09,12:19,12:38,12:50,13:06,13:20,13:30,13:51,14:08,14:20,14:35,15:05,15:21,15:35,16:08,16:21,16:31,16:56,17:21,17:27,18:04,19:04"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:35,7:30,7:58,8:09,8:31,8:41,9:07,9:36,9:52,10:06,10:21,10:37,10:52,11:06,11:23,11:36,11:55,12:09,12:20,12:39,12:50,13:06,13:21,13:30,13:51,14:08,14:21,14:35,15:06,15:22,15:35,16:08,16:22,16:31,16:57,17:21,17:27,18:04,19:05"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:36,7:31,8:00,8:10,8:32,8:42,9:08,9:37,9:53,10:07,10:22,10:37,10:53,11:07,11:24,11:37,11:56,12:10,12:21,12:39,12:51,13:07,13:22,13:31,13:52,14:10,14:23,14:38,15:07,15:23,15:36,16:09,16:23,16:32,16:58,17:22,17:29,18:05,19:05"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//
//    timeStr = [NSString stringWithFormat:@"6:37,7:31,8:00,8:11,8:32,8:43,9:08,9:39,9:55,10:08,10:23,10:39,10:55,11:08,11:25,11:37,11:57,12:11,12:22,12:40,12:53,13:07,13:24,13:31,13:52,14:11,14:23,14:39,15:07,15:23,15:36,16:11,16:23,16:32,16:58,17:22,17:30,18:05,19:05"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:37,7:32,8:01,8:12,8:33,8:43,9:09,9:40,9:55,10:10,10:24,10:40,10:56,11:09,11:25,11:38,11:58,12:12,12:22,12:41,12:54,13:08,13:25,13:32,13:53,14:12,14:24,14:40,15:08,15:24,15:37,16:11,16:24,16:33,16:59,17:23,17:31,18:05,19:06"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:38,7:32,8:01,8:13,8:33,8:44,9:10,9:40,9:56,10:10,10:24,10:40,10:57,11:10,11:26,11:39,11:58,12:13,12:23,12:41,12:54,13:08,13:25,13:32,13:53,14:12,14:24,14:41,15:08,15:24,15:37,16:12,16:24,16:33,16:59,17:24,17:31,18:06,19:06"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:39,7:33,8:02,8:14,8:34,8:45,9:11,9:41,9:56,10:11,10:25,10:41,10:57,11:11,11:26,11:40,11:59,12:14,12:23,12:42,12:55,13:09,13:26,13:33,13:54,14:13,14:25,14:41,15:09,15:26,15:38,16:12,16:25,16:34,17:00,17:25,17:32,18:06,19:07"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:39,7:33,8:02,8:14,8:35,8:45,9:11,9:41,9:56,10:11,10:25,10:42,10:58,11:11,11:26,11:41,11:59,12:14,12:24,18:42,12:56,13:09,13:26,13:33,13:54,14:13,14:25,14:41,15:09,15:26,15:38,16:13,16:25,16:34,17:00,17:25,17:32,18:07,19:07"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:39,7:34,8:03,8:15,8:36,8:45,9:12,9:42,9:58,10:11,10:26,10:42,10:58,11:12,11:27,11:42,11:59,12:14,12:25,12:43,12:57,13:10,13:27,13:34,13:55,14:14,14:25,14:42,15:10,15:27,15:39,16:13,16:26,16:35,17:01,17:25,17:33,18:08,19:08"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:40,7:34,8:03,8:16,8:37,8:46,9:12,9:42,9:59,10:12,10:26,10:43,10:59,11:13,11:27,11:43,12:00,12:15,12:26,12:43,12:57,13:12,13:27,13:35,13:56,14:14,14:26,14:42,15:11,15:28,15:39,16:14,16:27,16:36,17:02,17:26,17:33,18:08,19:09"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:40,7:35,8:04,8:17,8:38,8:46,9:13,9:43,10:00,10:13,10:27,10:44,11:00,11:14,11:28,11:44,12:00,12:16,12:26,12:44,12:58,13:12,13:28,13:36,13:57,14:16,14:27,14:43,15:12,15:29,15:40,16:15,16:28,16:37,17:03,17:27,17:34,18:09,19:10"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:40,7:35,8:04,8:17,8:38,8:47,9:14,9:45,10:01,10:13,10:29,10:46,11:01,11:15,11:29,11:44,12:01,12:18,12:28,12:44,12:59,13:13,13:28,13:36,13:57,14:17,14:27,14:44,15:14,15:29,15:42,16:15,16:28,16:37,17:03,17:28,17:35,18:09,19:10"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//
//    timeStr = [NSString stringWithFormat:@"6:41,7:36,8:05,8:18,8:39,8:47,9:15,9:45,10:01,10:14,10:29,10:46,11:02,11:15,11:30,11:45,12:02,12:18,12:29,12:45,12:58,13:14,13:29,13:37,13:58,14:17,14:28,14:45,15:14,15:30,15:43,16:16,16:29,16:38,17:04,17:28,17:36,18:09,19:11"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:42,7:37,8:05,8:18,8:40,8:48,9:15,9:46,10:02,10:15,10:30,10:47,11:03,11:15,11:30,11:45,12:03,12:19,12:30,12:45,13:00,13:15,13:30,13:38,13:59,14:18,14:28,14:46,15:15,15:31,15:45,16:16,16:30,16:39,17:05,17:29,17:36,18:10,19:11"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:43,7:38,8:06,8:19,8:42,8:49,9:18,9:47,10:03,10:16,10:32,10:48,11:04,11:17,11:33,11:48,12:05,12:21,12:32,12:47,13:01,13:21,13:31,13:39,14:01,14:19,14:29,14:47,15:17,15:32,15:46,16:17,16:32,16:41,17:07,17:30,17:38,18:11,19:12"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:43,7:39,8:07,8:20,8:42,8:50,9:19,9:48,10:03,10:17,10:33,10:50,11:04,11:18,11:34,11:50,12:06,12:23,12:32,12:47,13:02,13:22,13:32,13:40,14:02,14:20,14:30,14:48,15:18,15:33,15:47,16:18,16:32,16:42,17:07,17:30,17:39,18:11,19:12"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:44,7:40,8:07,8:21,8:43,8:52,9:20,9:49,10:04,10:18,10:34,10:51,11:05,11:20,11:35,11:50,12:07,12:24,12:34,12:48,13:03,13:24,13:32,13:41,14:03,14:22,14:31,14:50,15:20,15:34,15:49,16:19,16:34,16:43,17:08,17:31,17:41,18:12,19:13"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:45,7:41,8:08,8:22,8:44,8:54,9:21,9:50,10:05,10:20,10:35,10:53,11:08,11:21,11:37,11:52,12:09,12:25,12:36,12:49,13:05,13:25,13:34,13:42,14:04,14:23,14:32,14:52,15:22,15:35,15:51,16:20,16:35,16:44,17:09,17:32,17:43,18:13,19:14"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//    
//    timeStr = [NSString stringWithFormat:@"6:46,7:42,8:10,8:23,8:45,8:54,9:22,9:52,10:06,10:21,10:36,10:54,11:09,11:22,11:38,11:54,12:10,12:26,12:37,12:50,13:07,13:26,13:35,13:43,14:05,14:24,14:33,14:53,15:23,15:36,15:52,16:21,16:36,16:45,17:10,17:33,17:44,18:14,19:15"];
//    times = [self stopTimesArray:timeStr];
//    
//    [timeStop setObject:times forKey:@"times"];
//    
//    lat = [NSNumber numberWithDouble:-22.816603];
//    lng = [NSNumber numberWithDouble:-47.07293];
//    
//    [timeStop setObject:lat forKey:@"lat"];
//    [timeStop setObject:lng forKey:@"lg"];
//    
//    save = [StopTime createBusStopTimeWithDictionary:timeStop];
//
}

-(NSMutableArray*)stopTimesArray:(NSString*)timeStr
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
