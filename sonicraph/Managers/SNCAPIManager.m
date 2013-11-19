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

@implementation SNCAPIManager

NSString* token = @"SNCKL001527bedc56798a527bedc568b28527bedc56ac69";

+ (SNCAPIConnector*)connector
{
    static SNCAPIConnector* connector = nil;
    if(connector == nil){
        connector = [SNCAPIConnector sharedInstance];
    }
    return connector;
}
+ (void)createSonic:(SonicData *)sonic withCompletionBlock:(CompletionBlock)completionBlock
{
    NSString* sonicData = [[sonic dictionaryFromSonicData] JSONString];
    NSLog(@"length: %d",[sonicData lengthOfBytesUsingEncoding:NSStringEncodingConversionAllowLossy]);
    NSString* operation = @"create_sonic";
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token, @"latitude":[NSNumber numberWithFloat:sonic.latitude], @"longitude":[NSNumber numberWithFloat:sonic.longitude], @"sonic":sonicData}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         completionBlock(responseDictionary);
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) getUserSonics:(UserManagedObject*)user withCompletionBlock:(CompletionArrayBlock)completionBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    [SNCAPIManager
     getSonicsWithParams:@{
                           @"token":token,
                           @"count":count,
                           @"user":user.userId}
     saveToDatabase:NO
     withCompletionBlock:completionBlock];
}

+ (void) getSonicsBefore:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    [SNCAPIManager
     getSonicsWithParams:@{
                           @"token":token,
                           @"before_sonic":sonicManagedObject.sonicId,
                           @"count":count}
     saveToDatabase:YES
     withCompletionBlock:completionBlock];
}

+ (void) getSonicsAfter:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:token forKey:@"token"];
    if(sonicManagedObject != nil){
        [params setObject:sonicManagedObject.sonicId forKey:@"after_sonic"];
    }
    [params setObject:count forKey:@"count"];
    [SNCAPIManager
     getSonicsWithParams:params
     saveToDatabase:YES
     withCompletionBlock:completionBlock];
}

+ (void) getLatestSonicsWithCompletionBlock:(Block)completionBlock
{
    SonicManagedObject* lastSonic = [SonicManagedObject last];
    [SNCAPIManager getSonicsAfter:lastSonic withCompletionBlock:completionBlock];
}
+ (void)getSonicsWithParams:(NSDictionary *)dictionary saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(Block)completionBlock
{
    NSString* operation = @"get_sonics";
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:dictionary
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         for (NSDictionary* sonicDict in [responseDictionary objectForKey:@"sonics"]) {
             if (saveToDatabase){
                 [SNCAPIManager saveSonic:sonicDict];
             }
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicsAreLoaded object:nil];
         if(completionBlock){
             completionBlock();
         }
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (SonicManagedObject*) saveSonic:(NSDictionary*)sonicDict
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDictionary* userDict = [sonicDict objectForKey:@"user"];
    UserManagedObject* owner = [UserManagedObject createUserWith:[userDict objectForKey:@"id"] andUserName:[userDict objectForKey:@"username"] andRealName:[userDict objectForKey:@"realname"] andImage:[userDict objectForKey:@"profile_image"]];
    NSLog(@"%@",sonicDict);
    NSLog(@"%@",[formatter dateFromString:[sonicDict objectForKey:@"creation_date"]]);
    return [SonicManagedObject
            createWith:[sonicDict objectForKey:@"sonic_id"]
            andLongitude:[NSNumber numberWithFloat:[[sonicDict objectForKey:@"longitude"] floatValue]]
            andLatitude:[NSNumber numberWithFloat:[[sonicDict objectForKey:@"latitude"] floatValue]]
            andIsPrivate:[NSNumber numberWithBool:[[sonicDict objectForKey:@"longitude"] boolValue]]
            andCreationDate:[formatter dateFromString:[sonicDict objectForKey:@"creation_date"]]
            andSonicUrl:[sonicDict objectForKey:@"sonic_url"]
            andOwner:owner];
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

+ (void) getSonicsWithCompletionBlock:(Block)completionBlock
{
    
}

@end
