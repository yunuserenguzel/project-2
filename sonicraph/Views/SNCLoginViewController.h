//
//  SNCAuthenticationView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/9/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCLoginViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>

+ (SNCLoginViewController*) sharedInstance;

@property NSString* username;
@property NSString* password;
@property UITextField* usernameField;
@property UITextField* passwordField;
@property UIButton* loginButton;
@property UIButton* forgotPassword;

@property UILabel* titleLabel;

@end
