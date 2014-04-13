//
//  SNCLocalCacheManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonicData.h"
#import "TypeDefs.h"

#define SONIC_DATA_CACHE_LIMIT 100
#define FILE_TIMEOUT_INTERVAL 30 * 60 * 60 * 24
@interface SNCResourceHandler : NSObject

+ (SNCResourceHandler*) sharedInstance;

- (void) getSonicDataWithUrl:(NSURL*)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(RefreshBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock;

- (void) getImageWithUrl:(NSURL*)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(RefreshBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock;

- (void) clearAllCachedSonicData;

- (void) clearAllCachedImage;

- (void) clearTimeOutCachedSonicData;

- (void) clearTimeOutCachedImage;

- (void) clearCachedSonicDataWithUrls:(NSArray*)urls;

- (void) clearCachedImageWithUrls:(NSArray*)urls;

+ (NSString*) getAndCreateFolderAtApplicationDirectory:(NSString*)folderName;

@end    
