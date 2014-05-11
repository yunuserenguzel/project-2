//
//  SNCAppDelegate.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAppDelegate.h"

#import "SNCAPITest.h"
#import "SNCAPIManager.h"
#import "TypeDefs.h"
#import "SNCCameraViewController.h"

#import "AuthenticationManager.h"
#import "SonicPresenter.h"
#import "SNCResourceHandler.h"
#import <Crashlytics/Crashlytics.h>
#import "Configurations.h"

static SNCAppDelegate* sharedInstance = nil;

@implementation SNCAppDelegate

+ (SNCAppDelegate *)sharedInstance
{
    return sharedInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"d3de0613d3e232607b02e1bd842d3060e867ee96"];
    sharedInstance = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![[AuthenticationManager sharedInstance] token])
        {
            [[AuthenticationManager sharedInstance] displayAuthenticationView];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SNCResourceHandler sharedInstance] clearTimeOutCachedImage];
        [[SNCResourceHandler sharedInstance] clearTimeOutCachedSonicData];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
    
    [[UIActivityIndicatorView appearance] setColor:MainThemeColor];
    [[UIRefreshControl appearance] setTintColor:MainThemeColor];
    
    return YES;
}

- (void) reachabilityChangedNotification:(NSNotification*)notification
{
//    Reachability* reachability = notification.object;
    
    NSLog(@"%@\n%@",notification,notification.object);
}

- (void) userLoggedIn
{
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    if (!url) {  return NO; }
    
    if ([url.scheme isEqualToString:@"sonicraph"])
    {
        if([url.host isEqualToString:@"sonic"])
        {
            [[SonicPresenter sharedInstance] presentSonicWithId:url.lastPathComponent];
        }
        return YES;
        
    }
    else
    {
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
}
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        NSLog(@"%@",alertTitle);
        NSLog(@"%@",alertText);
        
        [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [[AuthenticationManager sharedInstance] checkAuthentication];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    [SNCAPIManager get:nil];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(application.applicationState != UIApplicationStateActive)
    {
        [self.tabbarController setSelectedIndex:3];
    }
}

- (UITabBarController *)tabbarController
{
    if([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        return (UITabBarController*)self.window.rootViewController;
    }
    return nil;
}

- (void) updateDeviceToken
{
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* deviceTokenStr = [deviceToken description];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    [SNCAPIManager registerDeviceToken:deviceTokenStr withCompletionBlock:^(NSDictionary *responseDictionary) {
        NSLog(@"device token registered successfully");
    } andErrorBlock:^(NSError *error) {
        NSLog(@"device token register failed with error: %@",error);
    }];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
