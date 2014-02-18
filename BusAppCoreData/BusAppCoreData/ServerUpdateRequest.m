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

-(void) requestServerUpdateWithVersion:(NSInteger)version withDelegate:(id<ServerUpdateRequestDelegate>)delegate
{
    [self setDelegate:delegate];
    
    //creates the request
    self.urlRequest = [NSURLRequest requestWithURL:[self makeServerURLWithVersion:version]];
    
    //fires the connection
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
	[self.connection start];
}

-(NSURL*) makeServerURLWithVersion:(int)version
{
    
    //creates the url of the servidor
    NSString *strURL = [NSString stringWithFormat:@"http://ec2-54-200-253-158.us-west-2.compute.amazonaws.com:8080/update?version=%d",version];
    
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
    NSError *error = nil;

    NSDictionary *parsedData = _data ? [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error] : nil;
    
    if (error)
    {
        if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.delegate request:self didFailWithError:error];
        }
        
        return;
    }
    
    //return for the supervisor the dictionary with the jsons names
    if([self.delegate respondsToSelector:@selector(request:didFinishWithObject:)])
    {
        [self.delegate request:self didFinishWithObject:parsedData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
    {
        [self.delegate request:self didFailWithError:error];
    }
}

@end
