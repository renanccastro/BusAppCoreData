//
//  NSMutableArray+UniqueArray.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "NSMutableArray+UniqueArray.h"

@implementation NSMutableArray (UniqueArray)


-(void) addUniqueArrayOfBus:(NSArray*)array{
	for (id object in array) {
		if (![self containsObject:object]) {
			[self addObject:object];
		}
	}
}
@end
