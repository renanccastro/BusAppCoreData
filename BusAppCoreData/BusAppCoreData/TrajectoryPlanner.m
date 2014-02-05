//
//  TrajectoryPlanner.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryPlanner.h"
#import "CoreDataAndRequestSupervisor.h"
#import "Interception+CoreDataMethods.h"

@implementation TrajectoryPlanner

- (NSArray *)planningFrom: (NSSet*)initial to: (NSSet *)final
{
    for (Bus_line* line in initial) {
        NSLog(@"initial: %@", line.full_name);
    }
	NSArray* initialLines = [initial allObjects];
	NSArray* finalLines = [final allObjects];
    for (Bus_line* line in finalLines) {
                    NSLog(@"mudou");
		for (Interception *interception in [Interception getAllInterceptionsForBus:line]){
            NSLog(@"bus: %@ final: %@", line.line_number,interception.bus_alvo.line_number);
        }
    }
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
			NSLog(@"Bus: %@", node.data.line_number);
			NSArray* array = [Interception getAllInterceptionsForBus:((Bus_line *)node.data)];
			for (Interception *interception in array){
                    [self.lines addObject: [[Node alloc] initWithData: interception.bus_alvo andParent: node]];
                    NSLog(@"LINHA: %@", interception.bus_alvo.full_name);

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
