//
//  TypeDefs.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/26/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#ifndef sonicraph_TypeDefs_h
#define sonicraph_TypeDefs_h


#define EditSonicSegue @"EditSonicSegue"
#define ShareSonicSegue @"ShareSonicSegue"
#define ProfileToPreviewSegue @"ProfileToPreviewSegue"
#define ViewSonicSegue @"ViewSonicSegue"
#define ProfileToFollowerFollowingSegue @"ProfileToFollowerFollowingSegue"
#define ProfileToSettingsSegue @"ProfileToSettingsSegue"
#define TabbarToLoginRegisterSegue @"TabbarToLoginRegisterSegue"
#define LoginToRegisterSegue @"LoginToRegisterSegue"


#define CommentsText @"Comments"
#define LikesText @"Likes"
#define ResonicsText @"Resonics"

#define NotificationSonicsAreLoaded @"NotificationSonicsAreLoaded"
#define NotificationLikeSonic @"NotificationLikeSonic"
#define NotificationDislikeSonic @"NotificationDislikeSonic"
#define NotificationOpenCommentsOfSonic @"NotificationOpenCommentsOfSonic"
#define NotificationSonicDeleted @"NotificationSonicDeleted"
#define NotificationCommentWrittenToSonic @"NotificationCommentWrittenToSonic"
#define NotificationUserLoggedIn @"NotificationUserLoggedIn"
#define NotificationUserSaved @"NotificationUserSaved"
#define NotificationSonicResoniced @"NotificationSonicResoniced"
#define NotificationSonicSaved @"NotificationSonicSaved"

UIColor* rgb(CGFloat red, CGFloat green, CGFloat blue);

CGRect CGRectByRatio(CGRect maxRect, CGRect minRect, CGFloat ratio);

@class User;
@protocol OpenProfileProtocol

- (void) openProfileForUser:(User*)user;

@end

@class Sonic;
typedef void (^CompletionArrayBlock) (NSArray *sonics);
typedef void (^CompletionUserBlock) (User *user,NSString* token);
typedef void (^CompletionBoolBlock) (BOOL successful);
typedef void (^CompletionSonicBlock) (Sonic* sonic);
typedef void (^CompletionIdBlock) (id object);

#endif
