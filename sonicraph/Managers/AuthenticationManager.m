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

#define AuthenticationManagerUserDefaultsTokenKey @"AuthenticationManagerUserDefaultsTokenKey"
#define AuthenticationManagerUserDefaultsUsernameKey @"AuthenticationManagerUserDefaultsUsernameKey"
#define AuthenticationManagerUserDefaultsPasswordKey @"AuthenticationManagerUserDefaultsPasswordKey"

static AuthenticationManager* sharedInstance = nil;

@implementation AuthenticationManager
{
    NSString* _token;
    NSString* _username;
    NSString* _password;
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
    if(self = [super init]){
        if(self.token){
            _isUserAuthenticated = YES;
        }else {
            _isUserAuthenticated = NO;
        }
    }
    return self;
}

- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                  shouldRemember:(BOOL)shouldRemember
             withCompletionBlock:(CompletionUserBlock)block
                   andErrorBlock:(ErrorBlock)errorBlock
{
    self.shouldRemember = shouldRemember;
    self.username = username;
    self.password = password;
    
    [SNCAPIManager loginWithUsername:@"yeguzel" andPassword:@"741285" withCompletionBlock:^(User *user,NSString* token) {
        NSLog(@"%@",user);
        self.token = token;
        self.authenticatedUser = user;
        _isUserAuthenticated = YES;
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

- (void) saveToUserDefaults:(NSString*)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (void) checkAuthentication
{
//    Actual Code
//    if(self.token == nil){
//        [self displayAuthenticationView];
//    }
    
//    Test Code
//    [self authenticateWithUsername:@"yeguzel" andPassword:@"741285" shouldRemember:YES withCompletionBlock:^(User *user) {
//        
//    } andErrorBlock:^(NSError *error) {
//        
//    }];
    
}

- (void) displayAuthenticationView
{
    SNCLoginViewController* loginViewController = [[SNCLoginViewController alloc] init];
    
    [[[SNCAppDelegate sharedInstance] tabbarController] presentViewController:loginViewController animated:YES completion:^{
        loginViewController.username = self.username;
        loginViewController.password = self.password;
    }];
}

@end
