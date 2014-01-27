//
//  ServerUpdateRequest.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "ServerUpdateRequest.h"

@interface ServerUpdateRequest () <NSURLConnectionDelegate>
{
    NSMutableData *_data;
}

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ServerUpdateRequest

-(void) requestServerUpdateWithVersion:(int)version withDelegate:(id<ServerUpdateRequestDelegate>)delegate
{
    [self setDelegate:delegate];
    
    //creates the request
    self.urlRequest = [NSURLRequest requestWithURL:[self makeServerURLWithVersion:version]];
    
    //fires the connection
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
}

-(NSURL*) makeServerURLWithVersion:(int)version
{
    
    //creates the url of the servidor
    NSString *strURL = [NSString stringWithFormat:@"127.0.0.1:8000/update?version=%d",version];
    
    NSURL *url = [NSURL URLWithString:strURL];
    
    return url;
    
}

#pragma mark - NSURLConnection Data Delegate Methods

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    _data = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

@end
