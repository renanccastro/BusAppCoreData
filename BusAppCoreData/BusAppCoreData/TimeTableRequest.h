//
//  TimeTableRequest.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 24/05/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bus_line.h"

@class TimeTableRequest;
@protocol TimeTableRequestDelegate <NSObject>

-(void)request:(TimeTableRequest*)request didFinishWithTimeJson:(id)json forBus:(Bus_line*)bus;
-(void)request:(TimeTableRequest*)request didFailInGetTimeJson:(NSError*)error;

@end


@interface TimeTableRequest : NSObject
@property (nonatomic, weak) id<TimeTableRequestDelegate> delegate;

-(void)requestTimeWithBus:(Bus_line *)bus withdelegate:(id<TimeTableRequestDelegate>)delegate;

@end
