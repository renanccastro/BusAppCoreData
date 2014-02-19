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
    
    bus.full_name = @"Circular 1";
    
    NSMutableDictionary *timeStop  = [[NSMutableDictionary alloc] init];
    [timeStop setObject:bus forKey:@"Bus"];
    
    NSMutableArray *times = [self stopTimesArray];
    
    [timeStop setObject:times forKey:@"times"];
    
    NSNumber *lat = [NSNumber numberWithDouble:-22.816603];
    NSNumber *lng = [NSNumber numberWithDouble:-47.072930];
    
    [timeStop setObject:lat forKey:@"lat"];
    [timeStop setObject:lng forKey:@"lg"];
    
    BOOL save = [StopTime createBusStopTimeWithDictionary:timeStop];
    
    if(!save)
    {
        //TODO
    }
}

-(NSMutableArray*)stopTimesArray
{
    NSMutableArray *times = [[NSMutableArray alloc] init];
    
    NSString *timeStr = @"6:43,7:38,8:6,8:19,8:41,8:49,9:16,9:46,10:2,10:15,10:31,10:47,11:3,11:16,11:31,11:47,12:4,12:20,12:30,12:46,13:1,13:15,13:31,13:39,14:0,14:18,14:29,14:46,15:16,15:31,15:45,16:17,16:31,16:40,17:6,17:29,17:37,18:10,19:11";
    
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
