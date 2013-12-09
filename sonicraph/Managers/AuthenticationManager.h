//
//  AuthenticationManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/1/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "SNCAPIManager.h"
@interface AuthenticationManager : NSObject


@property (readonly) AuthenticationManager* sharedInstance;

@property (nonatomic) NSString* token;
@property NSString* username;
@property NSString* password;
@property BOOL shouldRemember;
@property (readonly) BOOL isUserAuthenticated;

+ (AuthenticationManager *)sharedInstance;

- (void)authenticateWithUsername:(NSString *)username andPassword:(NSString *)password shouldRemember:(BOOL)shouldRemember withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;

- (void) checkAuthentication;

@end
