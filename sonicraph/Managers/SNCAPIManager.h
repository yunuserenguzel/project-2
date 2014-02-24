//
//  SNCAPIManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonicData.h"
#import "SNCAPIConnector.h"
#import "TypeDefs.h"
#import "SonicComment.h"
#import "Notification.h"

#define APIErrorCodeUsernameExist 212

User* userFromServerDictionary(NSDictionary* dictionary);
SonicComment* sonicCommentFromServerDictionary(NSDictionary* dictionary);
Sonic* sonicFromServerDictionary(NSDictionary* sonicDict);
Notification* notificationFromServerDictionary(NSDictionary* dict);

@interface SNCAPIManager : NSObject

+ (MKNetworkOperation *) createSonic:(SonicData *)sonic
                            withTags:(NSString*)tags
                 withCompletionBlock:(CompletionSonicBlock)completionBlock;



+ (MKNetworkOperation*)getSonicsWithParams:(NSMutableDictionary *)params
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) checkIsTokenValid:(NSString*)token
                      withCompletionBlock:(CompletionUserBlock)block
                            andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation *) registerWithUsername:(NSString*)username
                                        email:(NSString*)email
                                     password:(NSString*)password
                           andCompletionBlock:(CompletionUserBlock)completionBlock
                                andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation *) loginWithUsername:(NSString*) username
                               andPassword:(NSString*)password
                       withCompletionBlock:(CompletionUserBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) likeSonic:(Sonic*)sonic
              withCompletionBlock:(CompletionSonicBlock)completionBlock
                    andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) dislikeSonic:(Sonic*)sonic
                 withCompletionBlock:(CompletionSonicBlock)completionBlock
                       andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) resonicSonic:(Sonic*)sonic
                 withCompletionBlock:(CompletionSonicBlock)completionBlock
                       andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) deleteResonic:(Sonic*)sonic
                  withCompletionBlock:(CompletionSonicBlock)completionBlock
                        andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) deleteComment:(SonicComment*)sonicComment
                  withCompletionBlock:(CompletionBoolBlock)completionBlock
                        andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) deleteSonic:(Sonic*)sonic
                withCompletionBlock:(CompletionBoolBlock)completionBlock
                      andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getSonicsAfter:(Sonic*)sonic
                   withCompletionBlock:(CompletionArrayBlock)completionBlock
                         andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getSonicsBefore:(Sonic*)sonic
                    withCompletionBlock:(CompletionArrayBlock)completionBlock
                          andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getUserSonics:(User*)user
                               before:(Sonic*)sonic
                  withCompletionBlock:(CompletionArrayBlock)completionBlock
                        andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getCommentsOfSonic:(Sonic*)sonic
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) writeCommentToSonic:(Sonic*)sonic
                                   withText:(NSString*)text
                       withCompletionBlock:(CompletionIdBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getLikesOfSonic:(Sonic*)sonic
                    withCompletionBlock:(CompletionArrayBlock)completionBlock
                          andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getResonicsOfSonic:(Sonic*)sonic
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getFollowersOfUser:(User*) user
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getFollowingsOfUser:(User*) user
                        withCompletionBlock:(CompletionArrayBlock)completionBlock
                              andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) followUser:(User*)user
               withCompletionBlock:(CompletionBoolBlock)completionBlock
                     andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) unfollowUser:(User*)user
                 withCompletionBlock:(CompletionBoolBlock)completionBlock
                       andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getSonicsILikedwithCompletionBlock:(CompletionArrayBlock)completionBlock
                                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getSonicsWithSearchQuery:(NSString*)query
                             withCompletionBlock:(CompletionArrayBlock)completionBlock
                                   andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) getUsersWithSearchQuery:(NSString*)query
                            withCompletionBlock:(CompletionArrayBlock)completionBlock
                                  andErrorBlock:(ErrorBlock)errorBlock;
+ (MKNetworkOperation*) getNotificationsWithCompletionBlock:(CompletionArrayBlock)completionBlock
                                              andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) editProfileWithFields:(NSDictionary*) fields
                          withCompletionBlock:(CompletionUserBlock)completionBlock
                                andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) registerDeviceToken:(NSString*)deviceToken
                        withCompletionBlock:(CompletionBlock)completionBlock
                              andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) destroyAuthenticationWithCompletionBlock:(CompletionBlock)completionBlock
                              andErrorBlock:(ErrorBlock)errorBlock;

@end
