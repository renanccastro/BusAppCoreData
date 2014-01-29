//
//  Bus_points.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line;

@interface Bus_points : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSSet *onibus_que_passam;
@end

@interface Bus_points (CoreDataGeneratedAccessors)

- (void)addOnibus_que_passamObject:(Bus_line *)value;
- (void)removeOnibus_que_passamObject:(Bus_line *)value;
- (void)addOnibus_que_passam:(NSSet *)values;
- (void)removeOnibus_que_passam:(NSSet *)values;

@end
