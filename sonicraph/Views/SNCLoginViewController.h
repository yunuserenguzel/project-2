//
//  SNCAuthenticationView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/9/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCLoginViewController : UIViewController

+ (SNCLoginViewController*) sharedInstance;

@property UIWindow* window;
@property NSString* username;
@property NSString* password;
@property UITextField* usernameField;
@property UITextField* passwordField;
@property UIButton* registerButton;
@property UIButton* loginButton;

- (void) display;
- (void) close;

@end
