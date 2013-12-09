//
//  SNCAuthenticationView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/9/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCLoginViewController.h"
#import <QuartzCore/QuartzCore.h>

static SNCLoginViewController* sharedInstance = nil;

@implementation SNCLoginViewController

- (CGRect) usernameFieldFrame
{
    return CGRectMake(10.0, 100.0, 300.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(10.0, 200.0, 300.0, 50.0);
}

+ (SNCLoginViewController *)sharedInstance
{
    if (sharedInstance == nil){
        sharedInstance = [[SNCLoginViewController alloc] init];
    }
    return sharedInstance;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.usernameField = [[UITextField alloc] initWithFrame:[self usernameFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.view addSubview:self.usernameField];
    for(UITextField* textField in @[self.usernameField,self.passwordField]){
        textField.layer.borderColor = [UIColor redColor].CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius = 4.0f;
//        [textField.layer setRasterizationScale:YES];
//        [textField.layer setRasterizationScale:4.0f];
        textField.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:textField];
    }
    
    
}


@end
