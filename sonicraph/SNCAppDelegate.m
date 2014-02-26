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

#import "SNCSonicViewController.h"

static SNCAppDelegate* sharedInstance = nil;

@implementation SNCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (SNCAppDelegate *)sharedInstance
{
    return sharedInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sharedInstance = self;
    _tabbarController = (UITabBarController *)self.window.rootViewController;
    CGRect frame = CGRectMake(0.0, 0.0, 320, 48);//Setting a Frame.
    
    UIView* myTabView = [[UIView alloc] initWithFrame:frame];//Making Tab View
    
    // not supported on iOS4
    UITabBar *tabBarr = [self.tabbarController tabBar];
    if ([tabBarr respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBarr setBackgroundImage:[UIImage imageNamed:@"2013-11-07 09.52.53.png"]];
        
        
        // set for all
        // [[UITabBar appearance] setBackgroundImage: ...
    }
    else
    {
        // ios 4 code here
        //[tabBarr setBackgroundColor:c];
    }
    
    //[myTabView  setBackgroundColor:c];//Setting Color Of TaBar.
    
    [myTabView  setAlpha:0.8];//Setting Alpha of TabView.
    
    [[self.tabbarController tabBar] insertSubview:myTabView  atIndex:0];//Insert
//    NSLog(@"%@",[Sonic getFrom:1 to:1]);
    
//    [SNCAPIManager registerWithUsername:@"yeguzel" email:@"exculuber@gmail.com" password:@"741285" andCompletionBlock:^(NSDictionary *responseDictionary) {
//        NSString* validationCode = [responseDictionary objectForKey:@"validation_code"];
//        [SNCAPIManager validateWithEmail:@"exculuber@gmail.com" andValidationCode:validationCode withCompletionBlock:^(BOOL successful) {
//            [[AuthenticationManager sharedInstance] authenticateWithUsername:@"yeguzel" andPassword:@"741285" shouldRemember:YES withCompletionBlock:^(User *user, NSString* token) {
//                [[[UIAlertView alloc] initWithTitle:@"Successful!" message:@"Successfully Logged In!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//            } andErrorBlock:^(NSError *error) {
//                
//            }];
//        } andErrorBlock:^(NSError *error) {
//            NSLog(@"%@",error);
//        }];
//
//    } andErrorBlock:^(NSError *error) {
//        
//    }];
    
    //TEST
//    [SNCAPITest start];

    
//    [[AuthenticationManager sharedInstance] authenticateWithUsername:@"yeguzel" andPassword:@"741285" shouldRemember:YES withCompletionBlock:^(User *user, NSString* token) {
//        [[[UIAlertView alloc] initWithTitle:@"Successful!" message:@"Successfully Logged In!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//        [SNCAPIManager getUserSonics:[[AuthenticationManager sharedInstance] authenticatedUser] saveToDatabase:YES withCompletionBlock:^(NSArray *sonics) {
//        } andErrorBlock:^(NSError *error) {
//        }];
//    } andErrorBlock:^(NSError *error) {
//    }];
    NSLog(@"token: %@",[[AuthenticationManager sharedInstance] token]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AuthenticationManager sharedInstance] checkAuthentication];
    });
    
    return YES;
}

- (void) userLoggedIn
{
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
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
