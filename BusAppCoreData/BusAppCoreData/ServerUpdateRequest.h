//
//  ServerUpdateRequest.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerUpdateRequest;

@protocol ServerUpdateRequestDelegate <NSObject>

-(void) request:(ServerUpdateRequest*)request didFinishWithObject:(id)object;
-(void) request:(ServerUpdateRequest*)request didFailWithError:(NSError*)error;

@end

@interface ServerUpdateRequest : NSObject

@property (nonatomic, weak) id<ServerUpdateRequestDelegate> delegate;

-(void)requestServerUpdateWithVersion:(NSInteger)version withDelegate:(id<ServerUpdateRequestDelegate>)delegate;

@end
