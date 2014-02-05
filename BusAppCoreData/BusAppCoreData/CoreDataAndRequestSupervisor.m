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
	
//	if ([prefs integerForKey:@"version"] == nil) {
//		[prefs setObject:[[NSNumber alloc] initWithInt:0] forKey:@"version"];
//	}
	NSLog(@"%ld",(long)[prefs integerForKey:@"version"]);
    ServerUpdateRequest *serverUpdate = [[ServerUpdateRequest alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
    if(([currentDate timeIntervalSinceDate:[prefs objectForKey:@"last update"]] > 60*60*24*7) || ([prefs integerForKey:@"version"] == 0))
    {
        [serverUpdate requestServerUpdateWithVersion:[prefs integerForKey:@"version"]
                                        withDelegate:self];
    }
}

#pragma mark - server update delegate methods

-(void)request:(ServerUpdateRequest *)request didFailWithError:(NSError *)error
{
    //TODO
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
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self.requestsFeitas++;
		NSLog(@"requestsFeitas: %d\n", self.requestsFeitas);
		BOOL save = NO;
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
				NSLog(@"Started creating interseptions references");
				[Bus_line removeBusInterseptionsReferences];
				[Bus_line createBusInterseptionsReferences];
				NSLog(@"Finished creating interseptions references");
				[[NSUserDefaults standardUserDefaults] setInteger:self.newestVersion forKey:@"version"];
				self.finishedOperations = 0;
			}
        }
    }];
    [self.operations addObject:operation];
    [self.queue addOperation:operation];
}

#pragma mark - CoreData methods
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


@end
