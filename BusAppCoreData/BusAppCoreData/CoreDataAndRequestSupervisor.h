//
//  CoreDataAndRequestSupervisor.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocationExtension.h"

@class CoreDataAndRequestSupervisor;

@protocol CoreDataRequestDelegate <NSObject>

-(void) requestdidFinishWithObject:(id)object;
-(void) requestdidFailWithError:(NSError*)error;

@end

@protocol TreeDataRequestDelegate <NSObject>
 -(void) requestDataDidFinishWithInitialArray:(NSSet*)initial andWithFinal:(NSSet*)final;
-(void) requestdidFailWithError:(NSError*)error;

@end

@interface CoreDataAndRequestSupervisor : NSObject


@property (nonatomic, strong) NSString* lock;
@property (nonatomic) NSManagedObjectContext* context;
@property (nonatomic) id<CoreDataRequestDelegate> delegate;
@property (nonatomic) id<TreeDataRequestDelegate> treeDelegate;
@property (nonatomic) NSPersistentStoreCoordinator* coordinator;

-(NSNumber*)returnTimeInSeconds:(NSArray*)time;
-(void) requestBusLines;
-(NSManagedObjectContext*)newContext;
-(void) requestAllTimesTables;
+(CoreDataAndRequestSupervisor*) startSupervisor;
-(void) getAllBusPointsAsyncWithinDistance:(CGFloat)distance fromPoint:(CLLocationCoordinate2D)point;
-(void) getRequiredTreeLinesWithInitialPoint:(CLLocationCoordinate2D)initialPoint andFinalPoint:(CLLocationCoordinate2D)finalPoint withRange:(CGFloat)range;
-(void)circularUnicamp;

@end
