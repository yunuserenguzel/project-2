//
//  User.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "User.h"
#import "UserManagedObject.h"
#import "TypeDefs.h"

@implementation User

+ (User*) userWithId:(NSString*)userId andUsername:(NSString*)username andFullname:(NSString*)fullname andProfileImage:(NSString*)profile_image;

{
    User* user = [[User alloc] init];
    user.userId = userId;
    if([username isKindOfClass:[NSString class]]){
        user.username = username;
    }
    if([fullname isKindOfClass:[NSString class]]){
        user.fullName = fullname;
    }
    if([profile_image isKindOfClass:[NSString class]]){
        user.profileImageUrl = profile_image;
    }
//    user.profileImage = profile_image
    return user;
}

+ (User *)userWithManagedObject:(UserManagedObject *)userManagedObject
{
    User* user = [[User alloc] init];
    user.userManagedObject = userManagedObject;
    user.username = userManagedObject.username;
    user.userId = userManagedObject.userId;
    user.profileImageUrl = userManagedObject.image;
    user.followingCount = [userManagedObject.followingCount integerValue];
    user.followerCount = [userManagedObject.followerCount integerValue];
    user.sonicCount = [userManagedObject.sonicCount integerValue];
    user.website = userManagedObject.website;
    user.bio = userManagedObject.bio;
    user.location = userManagedObject.location;
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
    self.userManagedObject.username = self.username;
    self.userManagedObject.fullname = self.fullName;
    self.userManagedObject.image = self.profileImageUrl;
    self.userManagedObject.bio = self.bio;
    self.userManagedObject.website = self.website;
    self.userManagedObject.location = self.location;
    self.userManagedObject.followerCount = [NSNumber numberWithInteger:self.followerCount];
    self.userManagedObject.followingCount = [NSNumber numberWithInteger:self.followingCount];
    self.userManagedObject.sonicCount = [NSNumber numberWithInteger:self.sonicCount];
    [self.userManagedObject save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserSaved object:self];
}


@end
