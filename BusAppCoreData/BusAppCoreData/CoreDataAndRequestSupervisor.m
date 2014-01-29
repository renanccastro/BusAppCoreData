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
#import "JsonRequest.h"


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
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        BOOL save =[Bus_line saveBusLineWithDictionary:json];
        if(!save)
        {
            NSLog(@"i deu zica no save");
        }
        else
        {
            NSLog(@"Funfo mossu");
        }
    }];
    
    [self.queue addOperation:operation];
}

@end
