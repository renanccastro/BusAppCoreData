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

    NSMutableArray *route = [NSMutableArray alloc];
    self.head = [[Node alloc] initWithData: initialLines[0]];
    Node *node = self.head;
    NSInteger size = [finalLines count];
    
    for (NSInteger index = 1; index < size; index++){
        node.next = [[Node alloc] initWithData: initialLines[index]];
        node = node.next;
    }
    Node *end = node;
    
    BOOL find = NO;
    int i = 0, j = 0;
    NSInteger total = size;
    while (find != YES && node.next != nil && i < 3){
        NSInteger index = [finalLines indexOfObjectIdenticalTo: node.data];
        if (index != NSNotFound){
            find = YES;
            while (node != nil){
                [route addObject: node.data];
                node = node.parent;
            }
        }
//        } else {
//            if (j <= size){
//                node = node.next;
//                end.next = [[Node alloc] initWithData: node.data.INTER[0]];
//                
//                for (NSInteger index = 1; index < [node.data.INTER[0]; index++){
//                    end.next = [[Node alloc] initWithData: node.data.INTER[index]];
//                    end.next.parent = end;
//                    end = end.next;
//                }
//                total += [node.data.INTER[0]];
//                j++;
//            if (j == size){
//                i++;
//                size = total;
//            }
//            }
//        }
        
        
        else{
        if (j <= size){
            node = node.next;
            end.next = [[Node alloc] initWithData: [node.data.line_interceptions allObjects][0] ];
            
            for (NSInteger index = 1; index < [[node.data.line_interceptions allObjects] count]; index++){
                end.next = [[Node alloc] initWithData: [node.data.line_interceptions allObjects][index]];
                end.next.parent = end;
                end = end.next;
            }
                                               total += [[node.data.line_interceptions allObjects] count];
                                               j++;
                                               if (j == size){
                                                   i++;
                                                   size = total;
                                               }
                                               }
                                               }

    }
    return route;
}


@end
