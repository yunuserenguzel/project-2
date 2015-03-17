//
//  UserPool.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/17/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "UserPool.h"
#import "TypeDefs.h"

@interface UserPool ()

@property (readonly) NSMutableDictionary* users;

@end

static UserPool* sharedPool = nil;
@implementation UserPool

+ (UserPool *)sharedPool
{
    if(sharedPool == nil){
        sharedPool = [[UserPool alloc] init];
    }
    return sharedPool;
}


- (id)init
{
    if(self = [super init]){
        _users = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clean) name:NotificationUserLoggedOut object:nil];
    }
    return self;
}

- (void) clean
{
    sharedPool = nil;
}

- (User *)userForId:(NSString *)userId
{
    return [self.users objectForKey:userId];
}

- (User *)addOrUpdateUser:(User *)user
{
    if(user.userId == nil){
        NSLog(@"[UserPool.m %d]Warning! userId is nil",__LINE__);
        return nil;
    }
    User* cachedUser = [self userForId:user.userId];
    if(cachedUser)
    {
        [cachedUser updateWithUser:user];
    } else
    {
        cachedUser = user;
        [self.users setObject:cachedUser forKey:cachedUser.userId];
    }
    return cachedUser;
}

- (void)removeUser:(User *)user
{
    [self.users removeObjectForKey:user.userId];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
