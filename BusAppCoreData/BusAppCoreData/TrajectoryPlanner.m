//
//  TrajectoryPlanner.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TrajectoryPlanner.h"
#import "CoreDataAndRequestSupervisor.h"

@implementation TrajectoryPlanner

- (NSArray *)planningFrom: (NSArray*)initialLines to: (NSArray *)finalLines
{

    NSMutableArray *route = [[NSMutableArray alloc] init];
    self.head = [[Node alloc] initWithData: initialLines[0]];
    Node *node = self.head;
    NSInteger size = [finalLines count];
    
                      BOOL find = NO;
                  BOOL stop = NO;
    int i = 0, j = 0;
    while (i < [self.lines count] && find != YES && stop == NO){
        NSInteger index = [finalLines indexOfObjectIdenticalTo: ((Node*)self.lines[i]).data];
        if (index != NSNotFound){
            find = YES;
            while (((Node*)self.lines[i]).data != nil){
                [route addObject: ((Node*)self.lines[i]).data];
                self.lines[i] = ((Node*)self.lines[i]).parent;
            }
        }

        
    }
//        else {
//            if (j <= size){
//                node = node.next;
//                end.next = [[Node alloc] initWithData: [node.data.line_interceptions allObjects][0] ];
//            
//                for (NSInteger index = 1; index < [[node.data.line_interceptions allObjects] count]; index++){
//                    end.next = [[Node alloc] initWithData: [node.data.line_interceptions allObjects][index]];
//                    end.next.parent = end;
//                    end = end.next;
//                }
//                total += [[node.data.line_interceptions allObjects] count];
//                j++;
//                if (j == size){
//                    i++;
//                    size = total;
//                }
//            }
//        }
//
//    }
    return route;
}


@end
