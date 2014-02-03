//
//  Bus_line+Core_Data_Methods.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 29/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Bus_line.h"

@interface Bus_line (Core_Data_Methods)

+(BOOL) saveBusLineWithDictionary:(NSDictionary*)parsedData;
+(BOOL) createBusInterseptionsReferences;
+(void) removeBusInterseptionsReferences;

@end
