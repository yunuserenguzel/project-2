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
#import "SonicComment.h"
#import "UserPool.h"

NSDate* dateFromServerString(NSString* dateString)
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    return [dateFormatter dateFromString:dateString];
}

SonicComment* sonicCommentFromServerDictionary(NSDictionary* dictionary)
{
    SonicComment* sonicComment = [[SonicComment alloc] init];
    sonicComment.text = [dictionary objectForKey:@"text"];
    sonicComment.createdAt = dateFromServerString([dictionary objectForKey:@"created_at"]);
    User* user = [[User alloc] init];
    user.userId = [dictionary objectForKey:@"user_id"];
    [user setUsername:[dictionary objectForKey:@"username"]];
    [user setProfileImageUrl:[dictionary objectForKey:@"profile_image"]];
    sonicComment.user = user;
    return sonicComment;
}

id asClass(id object, Class class){
    return [object isKindOfClass:class] ? object : nil;
}

User* userFromServerDictionary(NSDictionary* dictionary, BOOL saveToDatabase){
    
    User* user = [[User alloc] init];
    user.userId = [dictionary objectForKey:@"id"];
    user.isBeingFollowed = [[dictionary objectForKey:@"is_being_followed"] boolValue];
    user.username = asClass([dictionary objectForKey:@"username"], [NSString class]);
    user.fullName = asClass([dictionary objectForKey:@"fullname"], [NSString class]);
    user.profileImageUrl = asClass([dictionary objectForKey:@"profile_image"], [NSString class]);
    user.website = asClass([dictionary objectForKey:@"website"], [NSString class]);
//    user.bio = asClass([dictionary objectForKey:@"bio"], [NSString class]);
    user.location = asClass([dictionary objectForKey:@"location"], [NSString class]);
    user.sonicCount = [asClass([dictionary objectForKey:@"sonic_count"], [NSNumber class]) integerValue];
    user.followerCount = [asClass([dictionary objectForKey:@"follower_count"], [NSNumber class]) integerValue];
    user.followingCount = [asClass([dictionary objectForKey:@"following_count"], [NSNumber class]) integerValue];
    return [[UserPool sharedPool] addOrUpdateUser:user];
    
}

Sonic* sonicFromServerDictionary(NSDictionary* sonicDict,BOOL saveToDatabase){
    NSDictionary* userDict = [sonicDict objectForKey:@"user"];
    User* user = userFromServerDictionary(userDict, saveToDatabase);
    Sonic* sonic = [[Sonic alloc] init];
    sonic.sonicId = asClass([sonicDict objectForKey:@"id"], [NSString class]);
    sonic.sonicUrl = asClass([sonicDict objectForKey:@"sonic_data"], [NSString class]);
    sonic.latitude = [asClass([sonicDict objectForKey:@"latitude"], [NSNumber class]) floatValue];
    sonic.longitude= [asClass([sonicDict objectForKey:@"longitude"],[NSNumber class]) floatValue];
    sonic.isPrivate = [asClass([sonicDict objectForKey:@"is_private" ], [NSNumber class]) boolValue];
    sonic.creationDate = dateFromServerString([sonicDict objectForKey:@"created_at"]);
    sonic.owner = user;
    sonic.likeCount = [asClass([sonicDict objectForKey:@"likes_count"], [NSNumber class]) integerValue];
    sonic.resonicCount = [asClass([sonicDict objectForKey:@"resonics_count"], [NSNumber class]) integerValue];
    sonic.commentCount = [asClass([sonicDict objectForKey:@"comments_count"], [NSNumber class]) integerValue];
    sonic.isLikedByMe = [asClass([sonicDict objectForKey:@"liked_by_me"], [NSNumber class]) boolValue];
    sonic.isResonicedByMe = [asClass([sonicDict objectForKey:@"resoniced_by_me"], [NSNumber class]) boolValue];
    return sonic;
}

@implementation SNCAPIManager
+ (MKNetworkOperation *)followUser:(User *)user withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user": user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/follow"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"], YES);
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
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"], YES);
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
                    [users addObject:userFromServerDictionary(userDict,NO)];
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
                     [users addObject:userFromServerDictionary(userDict,NO)];
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
                sonicComment.sonic = sonic;
                sonicComment.user = [[AuthenticationManager sharedInstance] authenticatedUser];
//                [[NSNotificationCenter defaultCenter]
//                 postNotificationName:NotificationCommentWrittenToSonic
//                 object:sonicComment];
//                if(completionBlock){
//                    completionBlock(sonicComment);
//                }
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"], NO);
                if(completionBlock){
                    completionBlock(sonicComment);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) deleteSonic:(Sonic*)sonic withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    
    [sonic deleteFromDatabase];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicDeleted object:sonic];
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/delete_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
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
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"], NO);
                if(completionBlock){
                    completionBlock(sonic);
                }
//                dispatch_async(dispatch_get_main_queue(),^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLikeSonic object:sonic];
//                });
//                if(completionBlock){
//                    completionBlock(sonic);
//                }
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
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"], NO);
                if(completionBlock){
                    completionBlock(sonic);
                }
//                dispatch_async(dispatch_get_main_queue(),^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDislikeSonic object:sonic];
//                });
//                
//                if(completionBlock){
//                    completionBlock(sonic);
//                }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)resonicSonic:(Sonic *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params useToken:YES andOperation:@"sonic/resonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"], NO);
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
                 Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"], NO);
                 if(completionBlock){
                     completionBlock(sonic);
                 }
             } andErrorBlock:errorBlock];
}

+ (void)createSonic:(SonicData *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock
{
    NSString* sonicData = [[sonic dictionaryFromSonicData] JSONString];
    NSString* tempFile = [SonicData filePathWithId:@"temp_sonic"];
    NSError* error;
    [sonicData writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString* operation = @"sonic/create_sonic";
    [[SNCAPIConnector sharedInstance]
     uploadFileRequestWithParams:@{ @"latitude":[NSNumber numberWithFloat:sonic.latitude], @"longitude":[NSNumber numberWithFloat:sonic.longitude]}
     useToken:YES
     andFiles:@[@{@"file":tempFile,@"key":@"sonic_data"}]
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         NSDictionary* sonicDict = [responseDictionary objectForKey:@"sonic"];
         Sonic* sonic = sonicFromServerDictionary(sonicDict, YES);
         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicsAreLoaded object:nil];
         completionBlock(sonic);
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) getUserSonics:(User*)user saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(user != nil){
        [params setObject:user.userId forKey:@"user"];
    }
    [params setObject:count forKey:@"count"];
    [SNCAPIManager getSonicsWithParams:params saveToDatabase:saveToDatabase withCompletionBlock:completionBlock andErrorBlock:errorBlock];
}
//
//+ (void) getSonicsBefore:(Sonic*)sonic withCompletionBlock:(Block)completionBlock
//{
//    NSNumber* count = [NSNumber numberWithInt:20];
//    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
//    [params setObject:token forKey:@"token"];
//    if(sonic != nil){
//        [params setObject:sonic.sonicId forKey:@"before_sonic"];
//    }
//    [params setObject:count forKey:@"count"];
//    [SNCAPIManager getSonicsWithParams:params saveToDatabase:YES withCompletionBlock:completionBlock andErrorBlock:nil];
//}
//
+ (MKNetworkOperation*) getSonicsAfter:(Sonic*)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(sonic != nil){
        [params setObject:sonic.sonicId forKey:@"after_sonic"];
    }
    [params setObject:count forKey:@"count"];
    
    return [SNCAPIManager getSonicsWithParams:params
                               saveToDatabase:YES
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (void) getSonicsWithCompletionBlock:(Block)completionBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

    [params setObject:count forKey:@"count"];
    [SNCAPIManager getSonicsWithParams:params
                        saveToDatabase:YES
                   withCompletionBlock:completionBlock andErrorBlock:nil];
}

+ (MKNetworkOperation*)getSonicsWithParams:(NSMutableDictionary *)params
                            saveToDatabase:(BOOL)saveToDatabase
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
                 if (saveToDatabase){
                     [sonics addObject:sonicFromServerDictionary(sonicDict, saveToDatabase)];
                 }
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicsAreLoaded object:nil];
             if(completionBlock){
                 completionBlock(sonics);
             }
            }
            andErrorBlock:errorBlock];
}


+ (void) getImage:(NSURL*)imageUrl withCompletionBlock:(CompletionIdBlock)completionBlock
{
    NSString* localFileUrl = [[SNCAPIManager imageCacheDirectory] stringByAppendingPathComponent:imageUrl.lastPathComponent];
    Block dispatchBlock = ^ {
        @autoreleasepool {
            if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
                NSData* data = [NSData dataWithContentsOfURL:imageUrl];
                [data writeToFile:localFileUrl atomically:YES];
                data = nil;
            }
            NSData* data = [NSData dataWithContentsOfFile:localFileUrl];
            UIImage* image = [UIImage imageWithData:data];
            completionBlock(image);
            data = nil;
        
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),dispatchBlock);
}

+ (void) getSonic:(NSURL*)sonicUrl withSonicBlock:(SonicBlock)sonicBlock
{
    NSString* localFileUrl = [[SNCAPIManager sonicCacheDirectory] stringByAppendingPathComponent:sonicUrl.lastPathComponent];
    Block dispatchBlock = ^ {
        @autoreleasepool {
            if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
                [[NSString stringWithContentsOfURL:sonicUrl encoding:NSUTF8StringEncoding error:nil] writeToFile:localFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            SonicData* sonic = [SonicData sonicDataFromFile:localFileUrl];
            sonic.remoteSonicDataFileUrl = sonicUrl;
            sonicBlock(sonic,nil);
         }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),dispatchBlock);
}

+ (NSString*) sonicCacheDirectory
{
    
    NSString* cacheFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"cached_sonics"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
    return cacheFolder;
}

+ (NSString*) imageCacheDirectory
{
    NSString* cacheFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"cached_images"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
    return cacheFolder;
}


+ (void) checkIsTokenValid:(NSString*)token withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;
{
    [[SNCAPIConnector sharedInstance]
     getRequestWithParams:@{@"token": token}
     useToken:NO
     andOperation:@"check_is_valid_token"
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         NSString* userId = [[responseDictionary objectForKey:@"user"] objectForKey:@"id"];
         User* user = [[User alloc] init];
         user.userId = userId;
         user.username = [[responseDictionary objectForKey:@"user"] objectForKey:@"username"];
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
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"],YES);
                if(completionBlock != nil){
                    completionBlock(user,token);
                }
    } andErrorBlock:errorBlock];
}


+ (MKNetworkOperation *)registerWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"username": username,
                             @"email":email,
                             @"password":password};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            useToken:NO
            andOperation:@"user/register"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSString* token = [responseDictionary objectForKey:@"token"];
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"],YES);
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
                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict, NO)];
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
                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict, NO)];
                    //                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];

}


@end






