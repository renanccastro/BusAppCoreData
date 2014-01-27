//
//  CoreDataAndRequestSupervisor.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreDataAndRequestSupervisor.h"
#import "ServerUpdateRequest.h"

@interface CoreDataAndRequestSupervisor () <ServerUpdateRequestDelegate>

@property (nonatomic, strong) UIManagedDocument * document;
@property (nonatomic, strong) NSArray *jsonsRequests;
@property (nonatomic, strong) ServerUpdateRequest *serverUpdate;

@end

@implementation CoreDataAndRequestSupervisor

-(void)requestBusLines
{
    
    
    
    
}

@end
