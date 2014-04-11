//
//  User.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "User.h"
#import "TypeDefs.h"
//#import "SNCAPIManager.h"
#import "UIImage+scaleToSize.h"
#import "Configurations.h"
#import "SNCResourceHandler.h"

@implementation User
{
    BOOL isInProcess;
    NSMutableArray* arrayOfCallBacksForThumbnail;
}

- (id)init
{
    if(self = [super init]){
        [self registerForNotification];
    }
    return self;
}

- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateWithNotification:)
     name:NotificationUpdateUser
     object:nil];
}

- (void) updateWithNotification:(NSNotification*)notification
{
    if(notification.object != self){
        [self updateWithUser:notification.object];
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.fullName forKey:@"fullName"];
    [encoder encodeObject:self.profileImageUrl forKey:@"profileImageUrl"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init]){
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.fullName = [decoder decodeObjectForKey:@"fullName"];
        self.profileImageUrl = [decoder decodeObjectForKey:@"profileImageUrl"];
        [self registerForNotification];
    }
    return self;
}

- (void) updateWithUser:(User*)user
{
    if([self.userId isEqualToString:[user userId]]){
        self.username = user.username;
        self.profileImageUrl = user.profileImageUrl;
        self.fullName = user.fullName;
        self.website = user.website;
        self.location = user.location;
        self.isBeingFollowed = user.isBeingFollowed;
        self.sonicCount = user.sonicCount;
        self.followerCount = user.followerCount;
        self.followingCount = user.followingCount;
        self.dateOfBirth = user.dateOfBirth;\
        self.gender = user.gender;
        [self fireUserUpdatedForViewNotification];
    }
}

- (void)fireUserUpdatedForViewNotification
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NotificationUpdateViewForUser
     object:self];
}

- (void)setProfileImageUrl:(NSString *)profileImageUrl
{
    if([_profileImageUrl isEqualToString:profileImageUrl] == NO){
        _profileImageUrl = profileImageUrl;
        self.thumbnailProfileImage = nil;
    }
}
- (void)getThumbnailProfileImageWithCompletionBlock:(CompletionIdBlock)completionBlock
{
    
    if(self.thumbnailProfileImage){
        if(completionBlock){
            completionBlock(self.thumbnailProfileImage);
        }
    }
    else {
        if(arrayOfCallBacksForThumbnail == nil){
            arrayOfCallBacksForThumbnail = [NSMutableArray new];
        }
        [arrayOfCallBacksForThumbnail addObject:completionBlock];
        if(isInProcess){
            return;
        }
        isInProcess = YES;
        [[SNCResourceHandler sharedInstance] getImageWithUrl:[NSURL URLWithString:self.profileImageUrl] withCompletionBlock:^(id object) {
            self.thumbnailProfileImage = [(UIImage*)object imageByScalingAndCroppingForSize:UserThumbnailSize];
            isInProcess = NO;
            [arrayOfCallBacksForThumbnail enumerateObjectsUsingBlock:^(CompletionIdBlock completionBlock, NSUInteger idx, BOOL *stop) {
                if(completionBlock){
//                    NSLog(@"calling completion block at index %d",idx);
                    completionBlock(self.thumbnailProfileImage);
                }
            }];
            arrayOfCallBacksForThumbnail = nil;
        } andRefreshBlock:nil andErrorBlock:^(NSError *error) {
            isInProcess = NO;
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
