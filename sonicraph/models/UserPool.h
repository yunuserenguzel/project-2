//
//  UserPool.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/17/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface UserPool : NSObject

@property (readonly) NSArray* allCachedUsers;

+ (UserPool*) sharedPool;

- (User*) userForId:(NSString*)userId;

- (User*) addOrUpdateUser:(User*) user;

- (void) removeUser:(User*) user;

@end
