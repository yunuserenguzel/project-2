//
//  SNCAPIManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"
#import "SNCAPIConnector.h"

@interface SNCAPIManager : NSObject

+ (void)createSonic:(Sonic *)sonic withCompletionBlock:(CompletionBlock)completionBlock;


@end
