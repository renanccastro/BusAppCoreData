//
//  TrajectoryPlanner.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryPlanner.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Interception.h"

@implementation TrajectoryPlanner

- (NSArray *)planningFrom: (NSArray*)initialLines to: (NSArray *)finalLines

{
//    for (Bus_line* line in initialLines) {
//        NSLog(@"initial: %@", line.full_name);
//    }

    NSMutableArray *route = [[NSMutableArray alloc] init];
    
    self.lines = [[NSMutableArray alloc] init];
    
    for (Bus_line *line in initialLines){
        [self.lines addObject: [[Node alloc] initWithData:line andParent: nil]];
    }
    
	BOOL found = NO;
	int i = 0, j = 0;
	Node *node;
	NSInteger size = [self.lines count];
    while (i < 3 && found != YES){
        node = self.lines[j];
        if ([finalLines containsObject: node.data]){
            found = YES;
            while (node.data != nil){
                [route addObject: node.data];
                node = node.parent;
            }
        } else if (i < 2){
//            NSLog(@"%d",[((Bus_line *)node.data).line_interceptions count]);
                for (Interception *interception in ((Bus_line *)node.data).line_interceptions){
                    [self.lines addObject: [[Node alloc] initWithData: interception.bus andParent: node]];
//                    NSLog(@"LINHA: %@", interception.bus.full_name);

                }
        }
        if (j == size - 1){
            i++;
            size = [self.lines count];
        }
        j++;
    }
    return route;
}

@end
