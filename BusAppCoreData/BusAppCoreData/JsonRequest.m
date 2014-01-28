//
//  JsonRequest.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "JsonRequest.h"

@interface JsonRequest ()
{
    NSMutableData *_data;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation JsonRequest

-(void)requestJsonWithName:(NSString *)name withdelegate:(id<JsonRequestDelegate>)delegate
{
    
    
}

-(NSURL*)makeJsonURLWithName:(NSString*)name
{

    NSString *urlString = [NSString stringWithFormat:@""];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
}

@end
