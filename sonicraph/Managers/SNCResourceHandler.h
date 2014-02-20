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

@interface SNCResourceHandler : NSObject

+ (SNCResourceHandler*) sharedInstance;

- (void) getSonicDataWithUrl:(NSURL*)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock;

- (void) getImageWithUrl:(NSURL*)url withCompletionBlock:(CompletionIdBlock)completionBlock andRefreshBlock:(FloatBlock)refreshBlock andErrorBlock:(ErrorBlock)errorBlock;

@end    
