//
//  JsonRequest.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "JsonRequest.h"

@interface JsonRequest () <NSURLConnectionDataDelegate>
{
    NSMutableData *_data;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation JsonRequest

-(void)requestJsonWithName:(NSString *)name withdelegate:(id<JsonRequestDelegate>)delegate
{
    [self setDelegate:delegate];

    //makes the request and fires its connection on the main loop
    self.request = [NSURLRequest requestWithURL:[self makeJsonURLWithName:name]];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                      delegate:self
                                              startImmediately:NO];
    
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
}

-(NSURL*)makeJsonURLWithName:(NSString*)name
{
    //makes the url for the requested json
    NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1:8000/get_json?file=%@",name];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
}

#pragma mark - NSURLConection Delegate

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _data = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"i deu zica");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    
    NSDictionary *parsedData = _data ? [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error] : nil;
    
    if (error)
    {
        if ([self.delegate respondsToSelector:@selector(request:didFailInGetJson:)])
        {
            [self.delegate request:self didFailInGetJson:error];
        }
        
        return;
    }
    
    //return the serializated json
    if ([self.delegate respondsToSelector:@selector(request:didFinishWithJson:)])
    {
        [self.delegate request:self didFinishWithJson:parsedData];
    }
    

}

@end
