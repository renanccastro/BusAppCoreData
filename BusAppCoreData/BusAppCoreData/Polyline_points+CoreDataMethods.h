//
//  Polyline_points+CoreDataMethods.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Polyline_points.h"

@interface Polyline_points (CoreDataMethods)

+(Polyline_points*) getPolyLinePointsWithLatitude:(double)lat andWithLongitude:(double)lng;
+(NSArray*) getBusLineTrajectory:(Bus_line*)bus withTurn:(NSString*)turn;

+(Polyline_points*) createPolylinePointIdaWithBus:(Bus_line*)bus withLat:(double)lat andLng:(double)lng withOrder:(int)order;
+(Polyline_points*) createPolylinePointVoltaWithBus:(Bus_line*)bus withLat:(double)lat andLng:(double)lng withOrder:(int)order;
-(void) removePointFromDatabase;


@end
