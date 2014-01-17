//
//  User.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "User.h"
#import "TypeDefs.h"
#import "SNCAPIManager.h"
#import "UIImage+scaleToSize.h"
#import "Configurations.h"

@implementation User
{
    BOOL isInProcess;
    NSMutableArray* arrayOfCallBacksForThumbnail;
    
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
    }

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
        [SNCAPIManager getImage:[NSURL URLWithString:self.profileImageUrl] withCompletionBlock:^(id object) {
            self.thumbnailProfileImage = [(UIImage*)object imageByScalingAndCroppingForSize:UserThumbnailSize];
            isInProcess = NO;
            [arrayOfCallBacksForThumbnail enumerateObjectsUsingBlock:^(CompletionIdBlock completionBlock, NSUInteger idx, BOOL *stop) {
                if(completionBlock){
                    NSLog(@"calling completion block at index %d",idx);
                    completionBlock(self.thumbnailProfileImage);
                }
            }];
            arrayOfCallBacksForThumbnail = nil;
        }];
    }
}



@end
