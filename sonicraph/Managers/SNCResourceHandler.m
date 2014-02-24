//
//  SNCLocalCacheManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCResourceHandler.h"
#import "JSONKit.h"

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
//    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(completionBlock)
    {
        completionBlock(receivedData);
    }
}
@end

@interface SNCResourceHandler ()

@property NSMutableArray* cachedSonicDataFiles;

@end


@implementation SNCResourceHandler
{
    NSLock* arrayLock;
}
+ (SNCResourceHandler *)sharedInstance
{
    static SNCResourceHandler* resourceHandler = nil;
    if(resourceHandler == nil)
    {
        resourceHandler = [[SNCResourceHandler alloc] init];

    }
    return resourceHandler;
}

- (id)init
{
    if(self = [super init])
    {
        self.cachedSonicDataFiles = [[NSMutableArray alloc] initWithCapacity:SONIC_DATA_CACHE_LIMIT];
        arrayLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)getImageWithUrl:(NSURL *)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage* image = [self getCachedImageWithUrl:url];
        if(image)
        {
            if(completionBlock)
            {
                completionBlock(image);
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getFileDataWithUrl:url withCompletionBlock:^(NSData* data) {
                    UIImage* image = [UIImage imageWithData:data];
                    [self cacheImage:image withUrl:url];
                    if(completionBlock)
                    {
                        completionBlock(image);
                    }
                } andRefreshBlock:refreshBlock andErrorBlock:errorBlock];
            });
        }
    });
}
- (void)getSonicDataWithUrl:(NSURL *)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        SonicData* sonicData = [self getCachedSonicDataWithUrl:url];
        if(sonicData)
        {
            if(completionBlock)
            {
                completionBlock(sonicData);
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getFileDataWithUrl:url withCompletionBlock:^(NSData* data) {
                    SonicData* sonicData = [SonicData sonicDataWithJsonDataString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                    [sonicData setRemoteSonicDataFileUrl:url];
                    [self cacheSonicData:sonicData withUrl:url];
                    if(completionBlock)
                    {
                        completionBlock(sonicData);
                    }
                } andRefreshBlock:refreshBlock andErrorBlock:errorBlock];
            });
        }
    });
}
- (void) getFileDataWithUrl:(NSURL*)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock
{
    ResourceDownloader* resourceDownloader = [[ResourceDownloader alloc] init];
    [resourceDownloader setFileURL:url];
    [resourceDownloader setRefreshBlock:refreshBlock];
    [resourceDownloader setErrorBlock:errorBlock];
    [resourceDownloader setCompletionBlock:completionBlock];
    [resourceDownloader startDownload];
}


#pragma mark Cache functions

- (UIImage*) getCachedImageWithUrl:(NSURL*)url
{
    NSString* localFileUrl = [[SNCResourceHandler imageCacheDirectory] stringByAppendingPathComponent:url.lastPathComponent];
    if([[NSFileManager defaultManager] fileExistsAtPath:localFileUrl])
    {
        return [[UIImage alloc] initWithContentsOfFile:localFileUrl];
    }
    return nil;
}

- (SonicData*) getCachedSonicDataWithUrl:(NSURL*)url
{
    NSString* localFileUrl = [[SNCResourceHandler sonicCacheDirectory] stringByAppendingPathComponent:url.lastPathComponent];
    SonicData* sonicData = [self retrieveSonicDataFromMemoryCacheWithUrl:url];
    if(sonicData)
    {
        return sonicData;
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:localFileUrl])
    {
        sonicData = [SonicData sonicDataFromFile:localFileUrl];
        sonicData.remoteSonicDataFileUrl = url;
        [self insertSonicDataToMemoryCache:sonicData];
    }
    
    return sonicData;
}

- (BOOL) insertSonicDataToMemoryCache:(SonicData*)sonicData
{
    [arrayLock lock];
    for(SonicData* currentSonicData in self.cachedSonicDataFiles)
    {
        if([[[currentSonicData remoteSonicDataFileUrl] path] isEqualToString:sonicData.remoteSonicDataFileUrl.path])
        {
            [arrayLock unlock];
            return NO;
        }
    }
    [self.cachedSonicDataFiles addObject:sonicData];
    if([self.cachedSonicDataFiles count] > SONIC_DATA_CACHE_LIMIT)
    {
        NSRange range = NSMakeRange(0, self.cachedSonicDataFiles.count - SONIC_DATA_CACHE_LIMIT);
        [self.cachedSonicDataFiles removeObjectsInRange:range];
    }
    [arrayLock unlock];
    return YES;
}

- (SonicData*) retrieveSonicDataFromMemoryCacheWithUrl:(NSURL*)url
{
    [arrayLock lock];
    SonicData* sonicDataToReturn;
    for(SonicData* sonicData in self.cachedSonicDataFiles)
    {
        if([[[sonicData remoteSonicDataFileUrl] path] isEqualToString:url.path])
        {
            sonicDataToReturn = sonicData;
        }
    }
    [arrayLock unlock];
    return sonicDataToReturn;
}

- (void) cacheSonicData:(SonicData*)sonicData withUrl:(NSURL*)url
{
    NSString* localFileUrl = [[SNCResourceHandler sonicCacheDirectory] stringByAppendingPathComponent:url.lastPathComponent];
    [self insertSonicDataToMemoryCache:sonicData];
    if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
        [[[sonicData dictionaryFromSonicData] JSONString] writeToFile:localFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
- (void) cacheImage:(UIImage*)image withUrl:(NSURL*)url
{
    NSString* localFileUrl = [[SNCResourceHandler imageCacheDirectory] stringByAppendingPathComponent:url.lastPathComponent];
    if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
         [UIImageJPEGRepresentation(image, 1.0) writeToFile:localFileUrl atomically:YES];
    }
}

+ (NSString*) sonicCacheDirectory
{
    static NSString* cacheFolder = nil;
    if(cacheFolder == nil)
    {
        cacheFolder = [SNCResourceHandler getAndCreateFolderAtApplicationDirectory:@"cached_sonics"];
    }
    return cacheFolder;
}

+ (NSString*) imageCacheDirectory
{
    static NSString* cacheFolder = nil;
    if(cacheFolder == nil)
    {
        cacheFolder = [SNCResourceHandler getAndCreateFolderAtApplicationDirectory:@"cached_images"];
    }
    return cacheFolder;
}
+ (NSString*) getAndCreateFolderAtApplicationDirectory:(NSString*)folderName
{
    NSString* cacheFolder;
    NSError* error;
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    cacheFolder = [[dirs objectAtIndex:0] stringByAppendingPathComponent:folderName];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:cacheFolder
     withIntermediateDirectories:YES
     attributes:nil
     error:&error];
    if(error)
    {
        NSLog(@"[SNCResourceHandler.m %d] %@",__LINE__,error);
    }
    [[NSURL fileURLWithPath:cacheFolder]
     setResourceValue:[NSNumber numberWithBool:YES]
     forKey:NSURLIsExcludedFromBackupKey
     error:&error];
    if(error)
    {
        NSLog(@"[SNCResourceHandler.m %d] %@",__LINE__,error);
    }
    return cacheFolder;
}

@end
