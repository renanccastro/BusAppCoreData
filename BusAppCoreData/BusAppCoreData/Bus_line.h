//
//  Bus_line.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bus_points, Interception, Polyline_points;

@interface Bus_line : NSManagedObject

@property (nonatomic, retain) NSString * full_name;
@property (nonatomic, retain) NSNumber * line_number;
@property (nonatomic, retain) NSNumber * web_number;
@property (nonatomic, retain) NSSet *line_interceptions;
@property (nonatomic, retain) NSSet *polyline_ida;
@property (nonatomic, retain) NSSet *polyline_volta;
@property (nonatomic, retain) NSSet *stops;
@property (nonatomic, retain) Interception *bus_alvo;
@end

@interface Bus_line (CoreDataGeneratedAccessors)

- (void)addLine_interceptionsObject:(Interception *)value;
- (void)removeLine_interceptionsObject:(Interception *)value;
- (void)addLine_interceptions:(NSSet *)values;
- (void)removeLine_interceptions:(NSSet *)values;

- (void)addPolyline_idaObject:(Polyline_points *)value;
- (void)removePolyline_idaObject:(Polyline_points *)value;
- (void)addPolyline_ida:(NSSet *)values;
- (void)removePolyline_ida:(NSSet *)values;

- (void)addPolyline_voltaObject:(Polyline_points *)value;
- (void)removePolyline_voltaObject:(Polyline_points *)value;
- (void)addPolyline_volta:(NSSet *)values;
- (void)removePolyline_volta:(NSSet *)values;

- (void)addStopsObject:(Bus_points *)value;
- (void)removeStopsObject:(Bus_points *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

@end
