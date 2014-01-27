//
//  CoreDataAndRequestSupervisor.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataAndRequestSupervisor : NSObject

@property (nonatomic) NSManagedObjectContext* context;
-(void) requestBusLines;

@end
