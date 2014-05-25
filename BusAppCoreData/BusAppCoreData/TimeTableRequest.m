//
//  TimeTableRequest.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 24/05/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "TimeTableRequest.h"

@interface TimeTableRequest () <NSURLConnectionDataDelegate>
{
    NSMutableData *_data;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) Bus_line *bus;

@end

@implementation TimeTableRequest

-(void)requestTimeWithBus:(Bus_line *)bus withdelegate:(id<TimeTableRequestDelegate>)delegate;
{
    [self setDelegate:delegate];
    self.bus = bus;
    //makes the request and fires its connection on the main loop
    self.request = [NSURLRequest requestWithURL:[self makeTimeURLWithWebNumber:bus.web_number]];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                      delegate:self
                                              startImmediately:NO];
    
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
}

-(NSURL*)makeTimeURLWithWebNumber:(NSNumber*)webNumber
{
    //makes the url for the requested json
    NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1:8000/get_time_json?lineNumber=%@",webNumber];
    
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
        if ([self.delegate respondsToSelector:@selector(request:didFailInGetTimeJson:)])
        {
            [self.delegate request:self didFailInGetTimeJson:error];
        }
        
        return;
    }
    
    //return the serializated json
    if ([self.delegate respondsToSelector:@selector(request:didFinishWithTimeJson:forBus:)])
    {
        [self.delegate request:self didFinishWithTimeJson:parsedData forBus:self.bus];
    }
    
    
}

@end
