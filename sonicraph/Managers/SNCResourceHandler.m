//
//  SNCLocalCacheManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCResourceHandler.h"

@interface ResourceDownloader : NSObject <NSURLConnectionDelegate>
{
    CompletionIdBlock completionBlock;
    ErrorBlock errorBlock;
    FloatBlock refreshBlock;
}
@property NSURL* fileURL;
- (void) setCompletionBlock:(CompletionIdBlock)completionBlock;
- (void) setErrorBlock:(ErrorBlock)errorBlock;
- (void) setRefreshBlock:(FloatBlock)refreshBlock;

- (void) startDownload;

@end

@implementation ResourceDownloader
{
    NSMutableData* receivedData;
    long long expectedBytes;
}

- (void)setCompletionBlock:(CompletionIdBlock)_completionBlock
{
    completionBlock = _completionBlock;
}

- (void)setErrorBlock:(ErrorBlock)_errorBlock
{
    errorBlock = _errorBlock;
}

- (void)setRefreshBlock:(FloatBlock)_refreshBlock
{
    refreshBlock = _refreshBlock;
}

-(void) startDownload
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.fileURL
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60];
    receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    [connection start];
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [receivedData setLength:0];
    expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    float progressive = (float)[receivedData length] / (float)expectedBytes;
    if(refreshBlock)
    {
        refreshBlock(progressive);
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(errorBlock)
    {
        errorBlock(error);
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(completionBlock)
    {
        completionBlock(receivedData);
    }
}
@end

@implementation SNCResourceHandler
+ (SNCResourceHandler *)sharedInstance
{
    static SNCResourceHandler* resourceHandler = nil;
    if(resourceHandler == nil)
    {
        resourceHandler = [[SNCResourceHandler alloc] init];
    }
    return resourceHandler;
}
- (void)getImageWithUrl:(NSURL *)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock
{
    
}

- (void)getSonicDataWithUrl:(NSURL *)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock
{
    ResourceDownloader* resourceDownloader = [[ResourceDownloader alloc] init];
    [resourceDownloader setFileURL:url];	
    [resourceDownloader setRefreshBlock:refreshBlock];
    [resourceDownloader setErrorBlock:errorBlock];
    [resourceDownloader setCompletionBlock:^(NSData* data) {
        SonicData* sonicData = [SonicData sonicDataWithJsonDataString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        [sonicData setRemoteSonicDataFileUrl:url];
        if(completionBlock)
        {
            completionBlock(sonicData);
        }
    }];
    [resourceDownloader startDownload];
}

@end
