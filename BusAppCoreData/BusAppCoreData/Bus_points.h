//
//  Bus_points.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line, Interception;

@interface Bus_points : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSSet *onibus_que_passam;
@property (nonatomic, retain) NSSet *interceptions;
@end

@interface Bus_points (CoreDataGeneratedAccessors)

- (void)addOnibus_que_passamObject:(Bus_line *)value;
- (void)removeOnibus_que_passamObject:(Bus_line *)value;
- (void)addOnibus_que_passam:(NSSet *)values;
- (void)removeOnibus_que_passam:(NSSet *)values;

- (void)addInterceptionsObject:(Interception *)value;
- (void)removeInterceptionsObject:(Interception *)value;
- (void)addInterceptions:(NSSet *)values;
- (void)removeInterceptions:(NSSet *)values;

@end
