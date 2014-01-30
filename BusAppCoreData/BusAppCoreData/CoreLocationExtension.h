//
//  CoreLocationExtension.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 30/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#define DegreesToRadians(degrees) degrees * M_PI / 180
#define RadiansToDegrees(radians) radians * 180 / M_PI

@interface CoreLocationExtension : NSObject

+ (CLLocationCoordinate2D) NewLocationFrom:(CLLocationCoordinate2D)startingPoint
						atDistanceInMeters:(float)distanceInMeters
                     alongBearingInDegrees:(double)bearingInDegrees;

@end
