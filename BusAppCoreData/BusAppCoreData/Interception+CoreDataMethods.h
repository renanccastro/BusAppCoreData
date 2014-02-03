//
//  Interception+CoreDataMethods.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Interception.h"

@interface Interception (CoreDataMethods)
+(Bus_points*) createInterceptionForBus:(Bus_line*)bus withInterceptionBus:(Bus_line*)line withPoint:(Bus_points*)stop;
@end
