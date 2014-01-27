//
//  CoreDataAndRequestSupervisor.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CoreDataAndRequestSupervisor;

@protocol CoreDataAndRequestSupervisorDelegate <NSObject>

-(void) request:(CoreDataAndRequestSupervisor*) request didFinishWithObject:(id)lines;
-(void) request:(CoreDataAndRequestSupervisor*) request didFailWithError:(NSError*)error;

@end

@interface CoreDataAndRequestSupervisor : NSObject

-(void) requestBusLinesWithDelegate:(id<CoreDataAndRequestSupervisorDelegate>)delegate;

@end
