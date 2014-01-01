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
#import "SonicManagedObject.h"
#import "UserManagedObject.h"
#import "TypeDefs.h"
#import "User.h"
#import "AuthenticationManager.h"
#import "SonicComment.h"

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
    return sonicComment;
}

@implementation SNCAPIManager

+ (MKNetworkOperation *)getCommentsOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"token":[[AuthenticationManager sharedInstance] token]};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            andOperation:@"sonic/comments"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)writeCommentToSonic:(Sonic *)sonic withText:(NSString *)text withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"text": text,
                             @"token" : [[AuthenticationManager sharedInstance] token]};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            andOperation:@"sonic/write_comment"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                SonicComment* sonicComment = sonicCommentFromServerDictionary([responseDictionary objectForKey:@"comment"]);
                sonicComment.sonic = sonic;
                sonicComment.user = [[AuthenticationManager sharedInstance] authenticatedUser];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationCommentWrittenToSonic
                 object:sonicComment];
                if(completionBlock){
                    completionBlock(sonicComment);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) deleteSonic:(Sonic*)sonic withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"token":[[AuthenticationManager sharedInstance] token]};
    
    [sonic deleteFromDatabase];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicDeleted object:sonic];
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:params andOperation:@"sonic/delete_sonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
        if(completionBlock){
            completionBlock(YES);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) likeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"token": [[AuthenticationManager sharedInstance] token]};
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:params andOperation:@"sonic/like_sonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
        Sonic* sonic = [SNCAPIManager sonicWithDictionary:[responseDictionary objectForKey:@"sonic"] saveToDatabase:NO];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLikeSonic object:sonic];
        });
        
        if(completionBlock){
            completionBlock(sonic);
        }
    } andErrorBlock:errorBlock];
}
+ (MKNetworkOperation*) dislikeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"token": [[AuthenticationManager sharedInstance] token]};
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:params andOperation:@"sonic/dislike_sonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
        Sonic* sonic = [SNCAPIManager sonicWithDictionary:[responseDictionary objectForKey:@"sonic"] saveToDatabase:NO];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDislikeSonic object:sonic];
        });
        
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
     uploadFileRequestWithParams:@{@"token":[[AuthenticationManager sharedInstance] token], @"latitude":[NSNumber numberWithFloat:sonic.latitude], @"longitude":[NSNumber numberWithFloat:sonic.longitude]}
     andFiles:@[@{@"file":tempFile,@"key":@"sonic_data"}]
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         NSDictionary* sonicDict = [responseDictionary objectForKey:@"sonic"];
         Sonic* sonic = [SNCAPIManager sonicWithDictionary:sonicDict saveToDatabase:YES];
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
    [params setObject:[[AuthenticationManager sharedInstance] token] forKey:@"token"];
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
//+ (MKNetworkOperation*) getSonicsAfter:(Sonic*)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
//{
//    NSNumber* count = [NSNumber numberWithInt:20];
//    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
//    [params setObject:token forKey:@"token"];
//    if(sonic != nil){
//        [params setObject:sonic.sonicId forKey:@"after_sonic"];
//    }
//    [params setObject:count forKey:@"count"];
//    
//    return [SNCAPIManager getSonicsWithParams:params
//                               saveToDatabase:YES
//                          withCompletionBlock:completionBlock
//                                andErrorBlock:errorBlock];
//}

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
    [params setObject:[AuthenticationManager sharedInstance].token forKey:@"token"];
    return [[SNCAPIConnector sharedInstance]
     getRequestWithParams:params
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         NSMutableArray* sonics = [[NSMutableArray alloc] init];
         for (NSDictionary* sonicDict in [responseDictionary objectForKey:@"sonics"]) {
             if (saveToDatabase){
                 [sonics addObject:[SNCAPIManager sonicWithDictionary:sonicDict saveToDatabase:saveToDatabase]];
             }
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicsAreLoaded object:nil];
         if(completionBlock){
             completionBlock(sonics);
         }
     }
     andErrorBlock:errorBlock];
}

+ (Sonic*) sonicWithDictionary:(NSDictionary*)sonicDict saveToDatabase:(BOOL)saveToDatabase
{
    NSDictionary* userDict = [sonicDict objectForKey:@"user"];
    User* user = [User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"realname"] andProfileImage:nil];
    if(saveToDatabase){
        [user saveToDatabase];
    }
    
    NSNumber* longitude = [sonicDict objectForKey:@"longitude"];
    longitude = [longitude isKindOfClass:[NSNull class]] ? nil : longitude;
    NSNumber* latitude = [sonicDict objectForKey:@"latitude"];
    latitude = [latitude isKindOfClass:[NSNull class]] ? nil :latitude;
    NSNumber* isPrivate = [sonicDict objectForKey:@"is_private" ];
    isPrivate = [isPrivate isKindOfClass:[NSNull class]] ? nil : isPrivate;
    NSString* sonicId = [NSString stringWithFormat:@"%@",[sonicDict objectForKey:@"id"]];
    NSDate* createdAt = dateFromServerString([sonicDict objectForKey:@"created_at"]);
    Sonic* sonic = [Sonic sonicWith:sonicId
                       andLongitude:longitude
                        andLatitude:latitude
                       andIsPrivate:isPrivate
                    andCreationDate:createdAt
                        andSonicUrl:[sonicDict objectForKey:@"sonic_data"]
                           andOwner:user];
    if(saveToDatabase){
        [sonic saveToDatabase];
    }
    return sonic;
}

+ (void) getSonic:(NSURL*)sonicUrl withSonicBlock:(SonicBlock)sonicBlock
{
    NSString* localFileUrl = [[SNCAPIManager sonicCacheDirectory] stringByAppendingPathComponent:sonicUrl.lastPathComponent];
    Block dispatchBlock = ^ {
        if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
            [[NSString stringWithContentsOfURL:sonicUrl encoding:NSUTF8StringEncoding error:nil] writeToFile:localFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        SonicData* sonic = [SonicData sonicDataFromFile:localFileUrl];
        sonic.remoteSonicDataFileUrl = sonicUrl;
        sonicBlock(sonic,nil);
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


+ (void) checkIsTokenValid:(NSString*)token withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;
{
    [[SNCAPIConnector sharedInstance] getRequestWithParams:@{@"token": token}
                                              andOperation:@"check_is_valid_token"
                                        andCompletionBlock:^(NSDictionary *responseDictionary) {
                                            NSString* userId = [[responseDictionary objectForKey:@"user"] objectForKey:@"id"];
                                            User* user = [User userWithId:userId];
                                            if(user == nil){
                                                user = [[User alloc] init];
                                                user.userId = userId;
                                                user.username = [[responseDictionary objectForKey:@"user"] objectForKey:@"username"];
                                                [user saveToDatabase];
                                            }
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
    
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:params andOperation:@"user/login"andCompletionBlock:^(NSDictionary *responseDictionary) {
        
        NSString* userId = [[responseDictionary objectForKey:@"user"] objectForKey:@"id"];
        NSString* token = [responseDictionary objectForKey:@"token"];
        User* user = [User userWithId:userId];
        if(user == nil){
            user = [[User alloc] init];
            user.userId = userId;
        }
        user.username = [[responseDictionary objectForKey:@"user"] objectForKey:@"username"];
        [user saveToDatabase];
        if(completionBlock != nil){
            completionBlock(user,token);
        }
    } andErrorBlock:errorBlock];
}


+ (MKNetworkOperation *)registerWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andCompletionBlock:(CompletionBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"username": username,
                             @"email":email,
                             @"password":password};
    return [[SNCAPIConnector sharedInstance] postRequestWithParams:params andOperation:@"user/register"andCompletionBlock:^(NSDictionary *responseDictionary) {
        if(completionBlock != nil){
            completionBlock(responseDictionary);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)validateWithEmail:(NSString *)email andValidationCode:(NSString *)validationCode withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"email": email,
                             @"validation_code": validationCode};
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:params andOperation:@"user/validate"andCompletionBlock:^(NSDictionary *responseDictionary) {
        if(completionBlock != nil){
            completionBlock(YES);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getLikesOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    
    NSDictionary* params = @{@"sonic":sonic.sonicId,
                             @"token":[[AuthenticationManager sharedInstance] token]};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            andOperation:@"sonic/likes"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    NSLog(@"%@",responseDictionary);
                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];
}


@end






