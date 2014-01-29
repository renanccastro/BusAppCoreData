//
//  Polyline_points.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_line;

@interface Polyline_points : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSSet *linhas_ida;
@property (nonatomic, retain) NSSet *linhas_volta;
@end

@interface Polyline_points (CoreDataGeneratedAccessors)

- (void)addLinhas_idaObject:(Bus_line *)value;
- (void)removeLinhas_idaObject:(Bus_line *)value;
- (void)addLinhas_ida:(NSSet *)values;
- (void)removeLinhas_ida:(NSSet *)values;

- (void)addLinhas_voltaObject:(Bus_line *)value;
- (void)removeLinhas_voltaObject:(Bus_line *)value;
- (void)addLinhas_volta:(NSSet *)values;
- (void)removeLinhas_volta:(NSSet *)values;

@end
