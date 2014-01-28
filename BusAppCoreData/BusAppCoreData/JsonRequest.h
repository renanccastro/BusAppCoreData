//
//  JsonRequest.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JsonRequest;

@protocol JsonRequestDelegate <NSObject>

-(void)request:(JsonRequest*)request didFinishWithJson:(id)json;
-(void)request:(JsonRequest*)request didFailInGetJson:(NSError*)error;

@end

@interface JsonRequest : NSObject

@property (nonatomic, weak) id<JsonRequestDelegate> delegate;

-(void)requestJsonWithName:(NSString*)name withdelegate:(id<JsonRequestDelegate>)delegate;

@end
