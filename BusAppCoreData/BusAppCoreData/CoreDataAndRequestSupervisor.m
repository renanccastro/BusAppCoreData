//
//  CoreDataAndRequestSupervisor.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreDataAndRequestSupervisor.h"

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

@end
