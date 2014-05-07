//
//  SNCAPIManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIManager.h"
#import "JSONKit.h"
#import "SonicData.h"
#import "TypeDefs.h"
#import "User.h"
#import "AuthenticationManager.h"
#import "UserPool.h"
#import "SNCResourceHandler.h"
#import "UIImage+Resize.h"

id asClass(id object, Class class)
{
    return [object isKindOfClass:class] ? object : nil;
}

NSDate* dateFromServerString(NSString* dateString)
{
    if (dateString == nil) {
        return nil;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    return [dateFormatter dateFromString:dateString];
}

NSDate* birthDayFromServerString(NSString* dateString)
{
    if(dateString == nil)
        return nil;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:dateString];
}

SonicComment* sonicCommentFromServerDictionary(NSDictionary* dictionary)
{
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]]){
        return nil;
    }
    SonicComment* sonicComment = [[SonicComment alloc] init];
    sonicComment.commentId = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
    sonicComment.text = [dictionary objectForKey:@"text"];
    sonicComment.createdAt = dateFromServerString(asClass([dictionary objectForKey:@"created_at"], [NSString class]));
    sonicComment.user = userFromServerDictionary([dictionary objectForKey:@"user"]);
    return sonicComment;
}


User* userFromServerDictionary(NSDictionary* dictionary)
{
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    User* user = [[User alloc] init];
    user.userId = [dictionary objectForKey:@"id"];
    user.isBeingFollowed = [[dictionary objectForKey:@"is_being_followed"] boolValue];
    user.username = asClass([dictionary objectForKey:@"username"], [NSString class]);
    user.fullName = asClass([dictionary objectForKey:@"fullname"], [NSString class]);
    user.profileImageUrl = asClass([dictionary objectForKey:@"profile_image"], [NSString class]);
    user.website = asClass([dictionary objectForKey:@"website"], [NSString class]);
    user.location = asClass([dictionary objectForKey:@"location"], [NSString class]);
    user.sonicCount = [asClass([dictionary objectForKey:@"sonic_count"], [NSNumber class]) integerValue];
    user.followerCount = [asClass([dictionary objectForKey:@"follower_count"], [NSNumber class]) integerValue];
    user.followingCount = [asClass([dictionary objectForKey:@"following_count"], [NSNumber class]) integerValue];
    user.dateOfBirth = birthDayFromServerString(asClass([dictionary objectForKey:@"date_of_birth"], [NSString class]));
    user.gender = asClass([dictionary objectForKey:@"gender"], [NSString class]);
    return [[UserPool sharedPool] addOrUpdateUser:user];
    
}

Sonic* sonicFromServerDictionary(NSDictionary* sonicDict)
{
    if(sonicDict == nil || [sonicDict isKindOfClass:[NSNull class]]){
        return nil;
    }
    NSDictionary* userDict = [sonicDict objectForKey:@"user"];
    User* user = userFromServerDictionary(userDict);
    Sonic* sonic = [[Sonic alloc] init];
    sonic.sonicId = asClass([sonicDict objectForKey:@"id"], [NSString class]);
    sonic.sonicUrlString = asClass([sonicDict objectForKey:@"sonic_data"], [NSString class]);
    sonic.tags = asClass([sonicDict objectForKey:@"tags"], [NSString class]);
    sonic.latitude = [asClass([sonicDict objectForKey:@"latitude"], [NSNumber class]) floatValue];
    sonic.longitude= [asClass([sonicDict objectForKey:@"longitude"],[NSNumber class]) floatValue];
    sonic.isPrivate = [asClass([sonicDict objectForKey:@"is_private" ], [NSNumber class]) boolValue];
    sonic.creationDate = dateFromServerString(asClass([sonicDict objectForKey:@"created_at"], [NSString class]));
    sonic.owner = user;
    sonic.sonicThumbnailUrlString = asClass([sonicDict objectForKey:@"sonic_thumbnail"], [NSString class]);
    sonic.shareUrlString = asClass([sonicDict objectForKey:@"share_url"], [NSString class]);
    sonic.likeCount = [asClass([sonicDict objectForKey:@"likes_count"], [NSNumber class]) integerValue];
    sonic.resonicCount = [asClass([sonicDict objectForKey:@"resonics_count"], [NSNumber class]) integerValue];
    sonic.commentCount = [asClass([sonicDict objectForKey:@"comments_count"], [NSNumber class]) integerValue];
    sonic.isLikedByMe = [asClass([sonicDict objectForKey:@"liked_by_me"], [NSNumber class]) boolValue];
    sonic.isResonicedByMe = [asClass([sonicDict objectForKey:@"resoniced_by_me"], [NSNumber class]) boolValue];
    sonic.isCommentedByMe = [asClass([sonicDict objectForKey:@"commented_by_me"], [NSNumber class]) boolValue];
    sonic.isResonic = [asClass([sonicDict objectForKey:@"is_resonic"], [NSNumber class]) boolValue];
    if(sonic.isResonic){
        sonic.originalSonic = sonicFromServerDictionary([sonicDict objectForKey:@"original_sonic"]);
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NotificationUpdateSonic
     object:sonic];
    return sonic;
}
Notification* notificationFromServerDictionary(NSDictionary* dict)
{
    Notification* notification = [[Notification alloc] init];
    notification.notificationId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    notification.notificationType = notificationTypeFromString([dict objectForKey:@"notification_type"]);
    notification.isRead = [asClass([dict objectForKey:@"is_read" ], [NSNumber class]) boolValue];
    notification.createdAt = dateFromServerString(asClass([dict objectForKey:@"created_at"], [NSString class]));
    notification.byUser = userFromServerDictionary([dict objectForKey:@"by_user"]);
    notification.toSonic = sonicFromServerDictionary([dict objectForKey:@"to_sonic"]);
    notification.sonicComment = sonicCommentFromServerDictionary([dict objectForKey:@"comment"]);
    return notification;
}

@implementation SNCAPIManager

+ (MKNetworkOperation *)resetPasswordForEmail:(NSString *)email withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:@{@"email": email} useToken:NO    andOperation:@"user/reset_password" andCompletionBlock:^(NSDictionary *responseDictionary) {
        BOOL result = [[responseDictionary objectForKeyedSubscript:@"result"] boolValue];
        if(completionBlock)
        {
            completionBlock(result);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)destroyAuthenticationWithCompletionBlock:(CompletionBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:@{} useToken:YES andOperation:@"user/destroy_authentication" andCompletionBlock:completionBlock  andErrorBlock:errorBlock];
}
+ (MKNetworkOperation *)registerDeviceToken:(NSString *)deviceToken withCompletionBlock:(CompletionBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:@{@"device_token": deviceToken,@"platform":@"ios"}
            useToken:YES
            andOperation:@"user/register_device_token"
            andCompletionBlock:completionBlock
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)editProfileWithFields:(NSDictionary *)fields withCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSMutableArray* files = [NSMutableArray new];
    NSMutableDictionary* params = [NSMutableDictionary new];
    for (NSString* key in [fields allKeys]) {
        id value = [fields objectForKey:key];
        if([value isKindOfClass:[UIImage class]])
        {
            NSString* tempFileUrl = [[[SNCResourceHandler getAndCreateFolderAtApplicationDirectory:@"temp"] stringByAppendingString:key] stringByAppendingString:@".jpg"];
            UIImage* resizedImage = [value resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
            [UIImageJPEGRepresentation(resizedImage, 1.0) writeToFile:tempFileUrl atomically:YES];
            [files addObject:@{@"file": tempFileUrl, @"key":key}];
        }
        else
        {
            [params setObject:value forKey:key];
        }
    }
    return [[SNCAPIConnector sharedInstance] uploadFileRequestWithParams:params useToken:YES andFiles:files andOperation:@"user/edit" andCompletionBlock:^(NSDictionary *responseDictionary) {
        User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
        if(completionBlock)
        {
            completionBlock(user,nil);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getNotificationsWithCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:@{} useToken:YES andOperation:@"noitifications/get_last_notifications" andCompletionBlock:^(NSDictionary *responseDictionary) {
        NSMutableArray* notifications = [NSMutableArray new];
        [[responseDictionary objectForKey:@"notifications"] enumerateObjectsUsingBlock:^(NSDictionary* dict, NSUInteger idx, BOOL *stop) {
            [notifications addObject:notificationFromServerDictionary(dict)];
        }];
        if(completionBlock){
            completionBlock(notifications);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getSonicsWithSearchQuery:(NSString *)query withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"query": query};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/search"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* sonics = [NSMutableArray new];
                [[responseDictionary objectForKey:@"sonics"] enumerateObjectsUsingBlock:^(NSDictionary* sonicDict, NSUInteger idx, BOOL *stop) {
                    Sonic* sonic = sonicFromServerDictionary(sonicDict);
                    [sonics addObject:sonic];
                }];
                if(completionBlock){
                    completionBlock(sonics);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getUsersWithSearchQuery:(NSString *)query withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"query": query};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/search"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [NSMutableArray new];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    User* user = userFromServerDictionary(userDict);
                    [users addObject:user];
                }];
                if(completionBlock){
                    completionBlock(users);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)followUser:(User *)user withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user": user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/follow"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"]);
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}
+ (MKNetworkOperation *)unfollowUser:(User *)user withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user": user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/unfollow"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"]);
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getFollowingsOfUser:(User *)user withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user" : user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/followings"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"followings"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    [users addObject:userFromServerDictionary(userDict)];
                }];
                if(completionBlock){
                    completionBlock(users);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getFollowersOfUser:(User *)user withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user" : user.userId};
    return  [[SNCAPIConnector sharedInstance]
             getRequestWithParams:params
             useToken:YES
             andOperation:@"user/followers"
             andCompletionBlock:^(NSDictionary *responseDictionary) {
                 NSMutableArray* users = [[NSMutableArray alloc] init];
                 [[responseDictionary objectForKey:@"followers"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                     [users addObject:userFromServerDictionary(userDict)];
                 }];
                 if(completionBlock){
                     completionBlock(users);
                 }
             } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getCommentsOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/comments"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* comments = [NSMutableArray new];
                [[responseDictionary objectForKey:@"comments"] enumerateObjectsUsingBlock:^(NSDictionary* commentDict, NSUInteger idx, BOOL *stop) {
                    SonicComment* comment = sonicCommentFromServerDictionary(commentDict);
                    comment.sonic = sonic;
                    [comments addObject:comment];
                }];
                if(completionBlock){
                    completionBlock(comments);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)writeCommentToSonic:(Sonic *)sonic withText:(NSString *)text withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"text": text};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/write_comment"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                SonicComment* sonicComment = sonicCommentFromServerDictionary([responseDictionary objectForKey:@"comment"]);
                sonicComment.sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                sonicComment.user = [[AuthenticationManager sharedInstance] authenticatedUser];

                if(completionBlock){
                    completionBlock(sonicComment);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)deleteComment:(SonicComment *)sonicComment withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"comment": sonicComment.commentId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/delete_comment"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationCommentDeleted
                 object:sonicComment];
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) deleteSonic:(Sonic*)sonic withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/delete_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicDeleted object:sonic];
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) likeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/like_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateSonic object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
            } andErrorBlock:errorBlock];
}
+ (MKNetworkOperation*) dislikeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/dislike_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateSonic object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)resonicSonic:(Sonic *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params useToken:YES andOperation:@"sonic/resonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                if(completionBlock){
                    completionBlock(sonic);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)deleteResonic:(Sonic *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return  [[SNCAPIConnector sharedInstance]
             getRequestWithParams:params useToken:YES andOperation:@"sonic/delete_resonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
                 Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                 if(completionBlock){
                     completionBlock(sonic);
                 }
                 
             } andErrorBlock:errorBlock];
}
+(MKNetworkOperation *)createSonic:(SonicData *)sonic withTags:(NSString *)tags withCompletionBlock:(CompletionSonicBlock)completionBlock
{
    NSString* sonicData = [[sonic dictionaryFromSonicData] JSONString];
    NSString* tempFile = [SonicData filePathWithId:@"temp_sonic"];
    NSError* error;
    [sonicData writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString* operation = @"sonic/create_sonic";
    return [[SNCAPIConnector sharedInstance]
            uploadFileRequestWithParams:@{@"tags":tags,
                                          @"latitude":[NSNumber numberWithFloat:sonic.latitude],
                                          @"longitude":[NSNumber numberWithFloat:sonic.longitude]}
            useToken:YES
            andFiles:@[@{@"file":tempFile,@"key":@"sonic_data"}]
            andOperation:operation
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSDictionary* sonicDict = [responseDictionary objectForKey:@"sonic"];
                Sonic* sonic = sonicFromServerDictionary(sonicDict);
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationNewSonicCreated
                 object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
            }
            andErrorBlock:^(NSError *error) {
                
            }];
}



+ (MKNetworkOperation*) getUserSonics:(User*)user before:(Sonic*)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:10];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(user){
        [params setObject:user.userId forKey:@"of_user"];
    }
    if(sonic)
    {
        [params setObject:sonic.sonicId forKey:@"before"];
    }
    else
    {
        [params setObject:[NSNumber numberWithInt:9] forKey:@"limit"];
    }
    [params setObject:count forKey:@"count"];
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}


+ (MKNetworkOperation *)getSonicsILikedwithCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"me_liked"];
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) getSonicsAfter:(Sonic*)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:10];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(sonic != nil){
        [params setObject:sonic.sonicId forKey:@"after"];
    }
    [params setObject:count forKey:@"count"];
    
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getSonicsBefore:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:10];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(sonic != nil){
        [params setObject:sonic.sonicId forKey:@"before"];
    }
    [params setObject:count forKey:@"count"];
    
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getSonicWithId:(NSString *)sonicId withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSString* operation = @"sonic/get_sonic";
    NSDictionary* params = @{@"sonic":sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:operation
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                if(completionBlock){
                    completionBlock(sonic);
                }
            }
            andErrorBlock:errorBlock];
}
+ (MKNetworkOperation*)getSonicsWithParams:(NSMutableDictionary *)params
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock
{
    NSString* operation = @"sonic/get_sonics";
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:operation
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* sonics = [[NSMutableArray alloc] init];
                for (NSDictionary* sonicDict in [responseDictionary objectForKey:@"sonics"]) {
                    [sonics addObject:sonicFromServerDictionary(sonicDict)];
                }
                if(completionBlock){
                    completionBlock(sonics);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) checkIsTokenValid:(NSString*)token withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;
{
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:@{@"token": token}
            useToken:NO
            andOperation:@"user/check_is_token_valid"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
                if(block != nil){
                    block(user,nil);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *) loginWithUsername:(NSString*) username andPassword:(NSString*)password withCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"username": username,
                             @"password": password};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:NO
            andOperation:@"user/login"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSString* token = [responseDictionary objectForKey:@"token"];
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
                if(completionBlock != nil){
                    completionBlock(user,token);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)registerWithEmail:(NSString *)email password:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"email":email,
                             @"password":password};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            useToken:NO
            andOperation:@"user/register"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSString* token = [responseDictionary objectForKey:@"token"];
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
                if(completionBlock != nil){
                    completionBlock(user,token);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getLikesOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/likes"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
//                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict)];
                    //                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getResonicsOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/resonics"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
//                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict)];
                    //                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];
    
}


@end






