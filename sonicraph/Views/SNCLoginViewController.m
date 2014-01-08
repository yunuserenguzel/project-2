//
//  SNCAuthenticationView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/9/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AuthenticationManager.h"
#import "TypeDefs.h"
#import "Configurations.h"

static SNCLoginViewController* sharedInstance = nil;

@implementation SNCLoginViewController

- (CGRect) usernameFieldFrame
{
    return CGRectMake(10.0, 100.0, 300.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(10.0, 170.0, 300.0, 50.0);
}

- (CGRect) loginButtonFrame
{
    return CGRectMake(10.0, 240.0, 300.0, 50.0);
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
    
//    [self.navigationController.navigationBar setHidden:NO];
    
    [self.navigationItem setTitle:@"Welcome!"];
    
    self.usernameField = [[UITextField alloc] initWithFrame:[self usernameFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.usernameField setPlaceholder:@"username"];
    [self.passwordField setPlaceholder:@"password"];
    
    [self.passwordField setSecureTextEntry:YES];
    
    [self.view addSubview:self.usernameField];
    for(UITextField* textField in @[self.usernameField,self.passwordField]){
        textField.layer.borderColor = NavigationBarBlueColor.CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius = 4.0f;
        [textField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)]];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        [textField.layer setRasterizationScale:YES];
//        [textField.layer setRasterizationScale:4.0f];
        textField.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:textField];
    }
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginButton.frame = [self loginButtonFrame];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(openRegisterForm)];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    
}
- (void) openRegisterForm
{
    [self performSegueWithIdentifier:LoginToRegisterSegue sender:self];
}
 - (void) login
{
    [[AuthenticationManager sharedInstance]
     authenticateWithUsername:self.usernameField.text
     andPassword:self.passwordField.text
     shouldRemember:YES
     withCompletionBlock:^(User *user, NSString *token) {
         [self dismissViewControllerAnimated:YES completion:^{
             
         }];
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}


@end
