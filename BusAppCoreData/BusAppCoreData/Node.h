//
//  Node.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 03/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bus_line.h"

@interface Node : NSObject

@property (nonatomic, strong) Bus_line* data;
@property (nonatomic, strong) Node* next;
@property (nonatomic, strong) Node* parent;

- (id)initWithData: (Bus_line *)data;

@end
