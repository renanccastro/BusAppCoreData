//
//  Interception+CoreDataMethods.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Interception.h"

@interface Interception (CoreDataMethods)
+(Interception*) createInterceptionForBus:(Bus_line*)line withInterceptionBus:(Bus_line*)bus withPoint:(Bus_points*)stop;
+(NSArray*) getAllInterceptionsForBus:(Bus_line*)bus;
+(void) createInterceptionForBus:(Bus_line*)line withSetOfInterceptions:(NSArray*)buses withPoint:(NSArray*)stop;
@end
