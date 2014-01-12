//
//  User.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserManagedObject;

@interface User : NSObject

+ (User*) userWithId:(NSString*)userId andUsername:(NSString*)username andFullname:(NSString*)fullname andProfileImage:(NSString*)profile_image;

+ (User*) userWithManagedObject:(UserManagedObject*)userManagedObject;

+ (User*) userWithId:(NSString*)userId;

- (void) saveToDatabase;


@property (nonatomic) NSString* userId;

@property (nonatomic) NSString* fullName;

@property (nonatomic) NSString* username;

@property NSString* bio;
@property NSString* website;
@property NSString* location;

@property (nonatomic) NSString* profileImageUrl;

@property (nonatomic) UserManagedObject* userManagedObject;

@property (nonatomic) BOOL isBeingFollowed;

@property NSInteger sonicCount;
@property NSInteger followerCount;
@property NSInteger followingCount;


@end
