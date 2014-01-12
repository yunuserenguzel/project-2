//
//  AuthenticationManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/1/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "AuthenticationManager.h"
#import "SNCAppDelegate.h"
#import "SNCLoginViewController.h"
#import "DatabaseManager.h"
#import "TypeDefs.h"

#define AuthenticationManagerUserDefaultsTokenKey @"AuthenticationManagerUserDefaultsTokenKey"
#define AuthenticationManagerUserDefaultsUsernameKey @"AuthenticationManagerUserDefaultsUsernameKey"
#define AuthenticationManagerUserDefaultsPasswordKey @"AuthenticationManagerUserDefaultsPasswordKey"
#define AuthenticationManagerUserDefaultsUserIdKey @"AuthenticationManagerUserDefaultsUserIdKey"

static AuthenticationManager* sharedInstance = nil;

@implementation AuthenticationManager
{
    NSString* _token;
    NSString* _username;
    NSString* _password;
    NSString* _userId;
}
+ (AuthenticationManager *)sharedInstance
{
    if(sharedInstance == nil){
        sharedInstance = [[AuthenticationManager alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(self = [super init]){
        if(self.token){
            _isUserAuthenticated = YES;
        }else {
            _isUserAuthenticated = NO;
        }
    }
    return self;
}


- (void)registerUserWithEmail:(NSString *)email andUsername:(NSString *)username andPassword:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    [SNCAPIManager registerWithUsername:username email:email password:password andCompletionBlock:^(User *user, NSString *token) {
        self.token = token;
        self.userId = user.userId;
        _isUserAuthenticated = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserLoggedIn object:nil];
        });
        if(completionBlock){
            completionBlock(user,token);
        }
    } andErrorBlock:^(NSError *error) {
        if(error.code == 300){
            _isUserAuthenticated = NO;
        }
        if(errorBlock){
            errorBlock(error);
        }
    }];
}


- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                  shouldRemember:(BOOL)shouldRemember
             withCompletionBlock:(CompletionUserBlock)block
                   andErrorBlock:(ErrorBlock)errorBlock
{
    
    [SNCAPIManager loginWithUsername:username andPassword:password withCompletionBlock:^(User *user,NSString* token) {
        NSLog(@"%@",user);
        if(shouldRemember){
            self.username = username;
            self.password = password;
        }
        self.token = token;
        self.userId = user.userId;
        _isUserAuthenticated = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserLoggedIn object:user];
        });
        if(block){
            block(user,token);
        }
    } andErrorBlock:^(NSError *error) {
        if(error.code == 300){
            _isUserAuthenticated = NO;
        }
        if(errorBlock){
            errorBlock(error);
        }
        NSLog(@"%@",error);
    }];
    
}

- (void)setToken:(NSString *)token
{
    _token = token;
    [self saveToUserDefaults:token forKey:AuthenticationManagerUserDefaultsTokenKey];
}

- (NSString *)token
{
    if(_token == nil){
        _token = [[NSUserDefaults standardUserDefaults] stringForKey:AuthenticationManagerUserDefaultsTokenKey];
    }
    return _token;
}

- (NSString *)userId
{
    if(_userId == nil){
        _userId = [[NSUserDefaults standardUserDefaults] stringForKey:AuthenticationManagerUserDefaultsUserIdKey];
    }
    return _userId;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    [self saveToUserDefaults:userId forKey:AuthenticationManagerUserDefaultsUserIdKey];

}


- (void)setUsername:(NSString *)username
{
    _username = username;
    if(!self.shouldRemember){
        [self saveToUserDefaults:nil forKey:AuthenticationManagerUserDefaultsUsernameKey];
    }
    else {
        [self saveToUserDefaults:username forKey:AuthenticationManagerUserDefaultsUsernameKey];
    }
}

- (NSString *)username
{
    if (_username == nil){
        _username = [[NSUserDefaults standardUserDefaults] stringForKey:AuthenticationManagerUserDefaultsUsernameKey];
    }
    return _username;
}

-  (void)setPassword:(NSString *)password
{
    _password = password;
    if(!self.shouldRemember){
        [self saveToUserDefaults:password forKey:AuthenticationManagerUserDefaultsPasswordKey];
    }else {
        [self saveToUserDefaults:nil forKey:AuthenticationManagerUserDefaultsPasswordKey];
    }
}

- (NSString *)password
{
    if (_password == nil){
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:AuthenticationManagerUserDefaultsPasswordKey];
    }
    return _password;
}

- (User *)authenticatedUser
{
    if(_authenticatedUser == nil){
        self.authenticatedUser = [User userWithId:self.userId];
    }
    return _authenticatedUser;
}

- (void) saveToUserDefaults:(NSString*)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout
{
//    [self setUsername:nil];
//    [self setPassword:nil];
    [self setUserId:nil];
    [self setToken:nil];
    [self setAuthenticatedUser:nil];
    [[DatabaseManager sharedInstance] flushDatabase];
    [self checkAuthentication];
}

- (void) checkAuthentication
{
//    Actual Code
    if(self.token == nil){
        [self displayAuthenticationView];
    }
    
//    Test Code
//    [self authenticateWithUsername:@"yeguzel" andPassword:@"741285" shouldRemember:YES withCompletionBlock:^(User *user) {
//        
//    } andErrorBlock:^(NSError *error) {
//        
//    }];
    
}

- (void) displayAuthenticationView
{
    UITabBarController* tabbarController = [[SNCAppDelegate sharedInstance] tabbarController];
    [[tabbarController viewControllers] enumerateObjectsUsingBlock:^(UINavigationController* navController, NSUInteger idx, BOOL *stop) {
        [navController popToRootViewControllerAnimated:NO];
    }];
    
    [tabbarController performSegueWithIdentifier:TabbarToLoginRegisterSegue sender:tabbarController];
}

@end
