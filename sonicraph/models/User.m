//
//  User.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "User.h"
#import "UserManagedObject.h"
@implementation User

+ (User *)userWithId:(NSString *)userId andUsername:(NSString *)username andProfileImage:(NSString *)profile_image
{
    User* user = [[User alloc] init];
    user.userId = userId;
    user.username = username;
//    user.profileImage = profile_image
    return user;
}

+ (User *)userWithManagedObject:(UserManagedObject *)userManagedObject
{
    User* user = [[User alloc] init];
    user.userManagedObject = userManagedObject;
    user.username = userManagedObject.name;
    user.userId = userManagedObject.userId;
    return user;
}


+ (User *)userWithId:(NSString*)userId
{
    UserManagedObject* userManagedObject = [UserManagedObject getUser:userId];
    if (userManagedObject == nil){
        return nil;
    }else {
        return [User userWithManagedObject:userManagedObject];
    }
}

- (void)saveToDatabase
{
    if(self.userManagedObject == nil){
        self.userManagedObject = [UserManagedObject createOrFetchWithId:self.userId];
    }
    self.userManagedObject.name = self.username;
    [self.userManagedObject save];
}

@end
