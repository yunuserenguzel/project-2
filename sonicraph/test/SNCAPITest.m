//
//  SNCAPITest.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPITest.h"
#import "SNCAPIConnector.h"

static NSString* token = @"SNCKL0015249c4d49c5355249c4d49c5435249c4d49c552";
//static NSNumber* pageNumber = [NSNumber numberWithInt:0];
//static NSNumber* pageCount = [NSNumber numberWithInt:20];
@implementation SNCAPITest

+ (void) start
{
    [SNCAPITest registerTest];
    [SNCAPITest loginTest];
    [SNCAPITest followUser];
    [SNCAPITest unfollowUser];
    [SNCAPITest getFollowedList];
    [SNCAPITest getFollowerList];
    [SNCAPITest createSonic];
    [SNCAPITest getMySonics];
    [SNCAPITest getSonicFeed];
    [SNCAPITest likeSonic];
}

+ (void) successLogForOperation:(NSString*)operationName
{
    NSLog(@"[SNCAPITest] successful operation: '%@'",operationName);
}

+ (void) failLogForOperation:(NSString*)operationName andError:(NSError*)error
{
    NSLog(@"[SNCAPITest] failed operation: '%@'\n\t\terror: %@",operationName,error);
}

+ (void) registerTest
{
    NSString* username = [NSString stringWithFormat:@"testuser%.10f",[[NSDate date] timeIntervalSince1970]];
    NSString* email = [NSString stringWithFormat:@"testuser%.10f@sonicraph.com",[[NSDate date] timeIntervalSince1970]];
//    NSString* username = @"yunus";
//    NSString* email = @"yunus@sonicraph.com";
    NSString* password = @"123456";
    NSString* platform = @"iOS";
    NSString* operation = @"register";
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"username":username,@"email":email,@"password":password,@"platform":platform}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         if([responseDictionary objectForKey:@"user_id"] && [responseDictionary objectForKey:@"token"]){
             [SNCAPITest successLogForOperation:operation];
         }else {
             [SNCAPITest failLogForOperation:operation andError:nil];
         }
         
     } andErrorBlock:^(NSError *error) {
         [SNCAPITest failLogForOperation:operation andError:error];
     }];
}

+ (void) loginTest
{
    NSString* username = @"exculuber@gmail.com";
    NSString* password = @"1234";
    NSString* operation = @"login";
    NSString* platform = @"iOS";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"user":username,@"password":password,@"platform":platform}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         if([responseDictionary objectForKey:@"token"]){
             [SNCAPITest successLogForOperation:operation];
         }
         else {
             [SNCAPITest failLogForOperation:operation andError:nil];
         }
    } andErrorBlock:^(NSError *error) {
        [SNCAPITest failLogForOperation:operation andError:error];
    }];
}

+ (void) resetPasswordTest
{
    NSLog(@"[SNCAPITest] resetPassword is not implemented yet");
}

+ (void) followUser
{
//    NSString* token = @"SNCKL0015249c4d49c5355249c4d49c5435249c4d49c552";
    NSString* userId = @"SNCKL0015255b0afbe7fd";
    NSString* operation = @"follow_user";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token": token, @"user_id":userId}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         if([responseDictionary objectForKey:@"success"] && [[responseDictionary objectForKey:@"success"] boolValue]){
             [SNCAPITest successLogForOperation:operation];
         }
         else {
             [SNCAPITest failLogForOperation:operation andError:nil];
         }
     } andErrorBlock:^(NSError *error) {
         [SNCAPITest failLogForOperation:operation andError:error];
    }];
}
+ (void) unfollowUser
{
//    NSString* token = @"SNCKL0015249c4d49c5355249c4d49c5435249c4d49c552";
    NSString* userId = @"SNCKL0015255b0afbe7fd";
    NSString* operation = @"unfollow_user";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token": token, @"user_id":userId}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         if([responseDictionary objectForKey:@"success"] && [[responseDictionary objectForKey:@"success"] boolValue]){
             [SNCAPITest successLogForOperation:operation];
         }
         else {
             [SNCAPITest failLogForOperation:operation andError:nil];
         }
     } andErrorBlock:^(NSError *error) {
         [SNCAPITest failLogForOperation:operation andError:error];
     }];
}

+ (void) getFollowedList
{
//    NSString* token = @"SNCKL0015249c4d49c5355249c4d49c5435249c4d49c552";
    int pageNumber = 0;
    int pageCount = 20;
    NSString* operation = @"get_followed_list";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token,@"page_number":[NSNumber numberWithInt:pageNumber],@"page_count":[NSNumber numberWithInt:pageCount]}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         NSLog(@"%@",responseDictionary);
    } andErrorBlock:^(NSError *error) {
        
    }];
}

+ (void) getFollowerList
{
//    NSString* token = @"SNCKL0015249c4d49c5355249c4d49c5435249c4d49c552";
    NSNumber* pageNumber = [NSNumber numberWithInt:0];
    NSNumber* pageCount = [NSNumber numberWithInt:20];
    NSString* operation = @"get_follower_list";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token,@"page_number":pageNumber,@"page_count":pageCount}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         
     }
     andErrorBlock:^(NSError *error) {

     }];
}

+ (void) createSonic
{
    NSData* sonic = [NSData data];
    NSString* operation = @"create_sonic";
    NSNumber* latitude = [NSNumber numberWithFloat:1.22123];
    NSNumber* longitude = [NSNumber numberWithFloat:1.1231];
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token, @"operation":operation, @"latitude":latitude, @"longitude":longitude, @"sonic":sonic}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) getMySonics
{
    NSNumber* pageNumber = [NSNumber numberWithInt:0];
    NSNumber* pageCount = [NSNumber numberWithInt:20];
    NSString* operation = @"get_my_sonics";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token,@"page_number":pageNumber,@"page_count":pageCount}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) getSonicFeed
{
    NSNumber* pageCount = [NSNumber numberWithInt:20];
    NSNumber* pageNumber = [NSNumber numberWithInt:0];
    NSString* operation = @"get_sonic_feed";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token,@"page_count":pageCount,@"page_number":pageNumber}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) likeSonic
{
    NSString* sonicId = @"asdasd";
    NSString* operation = @"like_sonic";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"sonic_id":sonicId,@"token":token}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

@end