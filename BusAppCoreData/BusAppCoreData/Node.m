//
//  Node.m
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "Node.h"

@implementation Node

- (id)initWithData: (Bus_line *)data andParent: (Node *)parent
{
    self = [super init];
    if (self) {
        self.data = data;
        self.parent = parent;
    }

    return self;
    
}


@end
