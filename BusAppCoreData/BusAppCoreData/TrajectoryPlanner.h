//
//  TrajectoryPlanner.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface TrajectoryPlanner : NSObject

@property (nonatomic, strong) NSMutableArray *lines;


- (NSArray *)planningFrom: (NSArray*)initialLines to: (NSArray *)finalLines;

@end
