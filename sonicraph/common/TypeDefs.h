//
//  TypeDefs.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/26/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#ifndef sonicraph_TypeDefs_h
#define sonicraph_TypeDefs_h


#define ErrorCodeUsernameOrPasswordIsWrong 320

#define EditSonicSegue @"EditSonicSegue"
#define ShareSonicSegue @"ShareSonicSegue"
#define ProfileToPreviewSegue @"ProfileToPreviewSegue"
#define ViewSonicSegue @"ViewSonicSegue"
#define ProfileToFollowerFollowingSegue @"ProfileToFollowerFollowingSegue"
#define ProfileToSettingsSegue @"ProfileToSettingsSegue"
#define HomeToProfileSegue @"HomeToProfileSegue"
#define SonicToProfileSegue @"SonicToProfileSegue"
#define FollowerFollowingToProfileSegue @"FollowerFollowingToProfileSegue"
#define SearchToProfileSegue @"SearchToProfileSegue"
#define SearchToSonicSegue @"SearchToSonicSegue"
#define EditProfileSegue @"EditProfileSegue"
#define ViewUserSegue @"ViewUserSegue"
#define ChangePasswordSegue @"ChangePasswordSegue"
#define AboutUsSegue @"AboutUsSegue"

#define CommentsText @"Comments"
#define LikesText @"Likes"
#define ResonicsText @"Resonics"

#define NotificationOpenCommentsOfSonic @"NotificationOpenCommentsOfSonic"
#define NotificationSonicDeleted @"NotificationSonicDeleted"
#define NotificationCommentWrittenToSonic @"NotificationCommentWrittenToSonic"
#define NotificationCommentDeleted @"NotificationCommentDeleted"

#define NotificationUserLoggedIn @"NotificationUserLoggedIn"
#define NotificationUserLoggedOut @"NotificationUserLoggedOut"
#define NotificationUpdateUser @"NotificationUpdateUser"
#define NotificationUpdateViewForUser @"NotificationUpdateViewForUser"

#define NotificationUpdateSonic @"NotificationUpdateSonic"
#define NotificationUpdateViewForSonic @"NotificationUpdateViewForSonic"
#define NotificationNewSonicCreated @"NotificationNewSonicCreated"

#define NotificationResonicDeleted @"NotificationResonicDeleted"

#define NotificationTabbarItemReSelected @"NotificationTabbarItemReSelected"

UIColor* rgb(CGFloat red, CGFloat green, CGFloat blue);

CGRect CGRectByRatio(CGRect maxRect, CGRect minRect, CGFloat ratio);

@class User;
@protocol OpenProfileProtocol

- (void) openProfileForUser:(User*)user;

@end
@class Sonic;
@protocol OpenSonicProtocol

- (void) openSonicDetails:(Sonic*)sonic;

@end

@class Sonic;
typedef void (^CompletionArrayBlock) (NSArray *sonics);
typedef void (^CompletionUserBlock) (User *user,NSString* token);
typedef void (^CompletionBoolBlock) (BOOL successful);
typedef void (^CompletionSonicBlock) (Sonic* sonic);
typedef void (^CompletionIdBlock) (id object);
typedef void (^CompletionDoubleIdBlock) (id object1,id object2);
typedef void (^RefreshBlock) (CGFloat ratio, NSURL* url);
typedef void (^ErrorBlock) (NSError *error);

#endif
