//
//  SNCFacebookManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SNCFacebookManager : NSObject

+ (void) loginWithCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

+ (void) grantPermissionWithCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

+ (void) postSonic:(Sonic *)sonic withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

+ (void) shareSonicWithDialog:(Sonic*)sonic withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

@end
