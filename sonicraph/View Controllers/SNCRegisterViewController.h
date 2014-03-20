//
//  SNCRegisterViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCRegisterViewController : UIViewController <UITextFieldDelegate>

@property UITextField* emailField;
@property UITextField* passwordField;

@property UIScrollView* scrollView;

@property UILabel* termsLabel;

@property UIButton* loginButton;

@property UILabel* titleLabel;
@end
