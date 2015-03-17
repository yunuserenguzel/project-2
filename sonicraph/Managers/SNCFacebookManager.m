//
//  SNCFacebookManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCFacebookManager.h"
#import "SNCAppDelegate.h"

@implementation SNCFacebookManager

+ (void)loginWithCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    
    // Open a session showing the user the login UI
    // You must ALWAYS ask for basic_info permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         // Retrieve the app delegate
         SNCAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
         if(!error)
         {
             if(completionBlock)
             {
                 completionBlock(session);
             }
         }
         else
         {
             if(errorBlock)
             {
                 errorBlock(error);
             }
         }
     }];
}

+ (void)grantPermissionWithCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSArray *permissionsNeeded = @[@"publish_actions"];
    if([[FBSession activeSession] state] == FBSessionStateOpen || [[FBSession activeSession] state] == FBSessionStateOpenTokenExtended)
    {
        // Request the permissions the user currently has
        [FBRequestConnection
         startWithGraphPath:@"/me/permissions"
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error){
                 NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                 NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                 
                 // Check if all the permissions we need are present in the user's current permissions
                 // If they are not present add them to the permissions to be requested
                 for (NSString *permission in permissionsNeeded){
                     if (![currentPermissions objectForKey:permission]){
                         [requestPermissions addObject:permission];
                     }
                 }
                 
                 // If we have permissions to request
                 if ([requestPermissions count] > 0){
                     // Ask for the missing permissions
                     [FBSession.activeSession
                      requestNewPublishPermissions:requestPermissions
                      defaultAudience:FBSessionDefaultAudienceFriends
                      completionHandler:^(FBSession *session, NSError *error) {
                          if (!error) {
                              if(completionBlock)
                              {
                                  completionBlock(session);
                              }
                          } else {
                              // An error occurred, handle the error
                              // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                              NSLog(@"%@", error.description);
                              
                              if(errorBlock)
                              {
                                  errorBlock(error);
                              }
                          }
                      }];
                 }
                 else
                 {
                     // Permissions are present, we can request the user information
                     //                                          [self makeRequestToShareLink];
                 }
                 
             } else {
                 // There was an error requesting the permission information
                 // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                 NSLog(@"%@", error.description);
                 [FBSession.activeSession closeAndClearTokenInformation];
                 [FBSession.activeSession close];
                 [FBSession setActiveSession:nil];
                 if(errorBlock)
                 {
                     errorBlock(error);
                 }
             }
         }];
    }
    else
    {
        [SNCFacebookManager loginWithCompletionBlock:^(id object) {
            [self grantPermissionWithCompletionBlock:completionBlock andErrorBlock:errorBlock];
        } andErrorBlock:errorBlock];
    }

}

+ (void)postSonic:(Sonic *)sonic withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSString* fullNameFild = [NSString stringWithFormat:@"%@ took a sonic", sonic.owner.fullName];
    NSString* name = sonic.tags ? sonic.tags : @"Sonicraph";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   name, @"name",
                                   fullNameFild, @"caption",
                                   @"sonicraph.com", @"description",
                                   sonic.shareUrlString, @"link",
                                   nil];
    
        [FBRequestConnection
         startWithGraphPath:@"/me/feed"
         parameters:params
         HTTPMethod:@"POST"
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 // Link posted successfully to Facebook
                 NSLog(@"result: %@", result);
                 if(completionBlock)
                 {
                     completionBlock(connection);
                 }
             } else {
                 // An error occurred, we need to handle the error
                 // See: https://developers.facebook.com/docs/ios/errors
                 NSLog(@"%@", error.description);
                 if(errorBlock)
                 {
                     errorBlock(error);
                 }
             }
         }];


}

+ (void) shareSonicWithDialog:(Sonic*)sonic withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{

    NSString* fullNameFild = [NSString stringWithFormat:@"%@ took a sonic", sonic.owner.fullName];
    NSString* name = sonic.tags ? sonic.tags : @"Sonicraph";
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:sonic.shareUrlString];
    params.name = name;
    params.caption = fullNameFild;
//    params.description = @"sonicraph.com";
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs
         presentShareDialogWithLink:params.link
         name:params.name
         caption:params.caption
         description:params.description
         picture:params.picture
         clientState:nil
         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
             if(!error) {
                 if(completionBlock)
                 {
                     completionBlock(results);
                 }
             } else {
                 if(errorBlock)
                 {
                     errorBlock(error);
                 }
             }
         }];
    } else {
        
    }
}

@end
