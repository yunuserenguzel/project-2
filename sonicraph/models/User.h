//
//  User.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefs.h"


@interface User : NSObject <NSCoding>

@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* fullName;
@property (nonatomic) NSString* username;

@property NSString* website;
@property NSString* location;

@property NSString* gender;
@property NSDate* dateOfBirth;

@property (nonatomic) NSString* profileImageUrl;
@property (nonatomic) UIImage* thumbnailProfileImage;

@property (nonatomic) BOOL isBeingFollowed;

@property NSInteger sonicCount;
@property NSInteger followerCount;
@property NSInteger followingCount;

- (void) getThumbnailProfileImageWithCompletionBlock:(CompletionDoubleIdBlock)completionBlock;
- (void) updateWithUser:(User*)user;
- (void) fireUserUpdatedForViewNotification;
@end
