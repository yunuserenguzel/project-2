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
#import "SNCGoThroughViewController.h"

#define ResetPasswordConfirmAlertViewTag 123123

static SNCLoginViewController* sharedInstance = nil;

@implementation SNCLoginViewController

- (CGRect) titleLabelFrame
{
    return CGRectMake(0.0, 15.0, 320.0, 50.0);
}

- (CGRect) usernameFieldFrame
{
    return CGRectMake(0.0, 80.0, 320.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(0.0, 132.0, 320.0, 50.0);
}

- (CGRect) forgotPasswordFrame
{
    return CGRectMake(10.0, 200.0, 300.0, 50.0);
}

- (CGRect) loginButtonFrame
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
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setText:@"Log in"];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:26.0]];
    
    self.usernameField = [[UITextField alloc] initWithFrame:[self usernameFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.usernameField setPlaceholder:@"Username"];
    [self.passwordField setPlaceholder:@"Password"];
    [self.passwordField setSecureTextEntry:YES];
    
    [self.view addSubview:self.usernameField];
    for(UITextField* textField in @[self.usernameField,self.passwordField]){
        UIView* base = textFieldWithBaseAndLabel(textField);
        [textField setDelegate:self];
        [self.view addSubview:base];
    }
    
    [self.usernameField setPlaceholder:@"or e-mail"];
    
    [self.usernameField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
    
    self.forgotPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPassword setFrame:[self forgotPasswordFrame]];
    [self.forgotPassword setTitle:@"Forgot Password ? " forState:UIControlStateNormal];
    [self.forgotPassword addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgotPassword];
    
    
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void) resetPassword
{
    if(self.usernameField.text.length > 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password ?" message:@"Press OK to receive reset password email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        alert.tag = ResetPasswordConfirmAlertViewTag;
        [alert show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Write your email to receive reset password mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ResetPasswordConfirmAlertViewTag)
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [indicator setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
            [self.view addSubview:indicator];
            [indicator startAnimating];
            [self.view setUserInteractionEnabled:NO];
            [SNCAPIManager resetPasswordForEmail:self.usernameField.text withCompletionBlock:^(BOOL successful) {
                [indicator removeFromSuperview];
                [self.view setUserInteractionEnabled:YES];
                [self.usernameField setText:nil];
                [[[UIAlertView alloc] initWithTitle:@"Successful" message:@"Your reset password request is successfully completed. Please check your inbox" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            } andErrorBlock:^(NSError *error) {
                [indicator removeFromSuperview];
                [self.view setUserInteractionEnabled:YES];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }];
        }
    }
}

- (void) closeKeyboard
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(textField == self.passwordField)
    {
        [self.view endEditing:YES];
        [self login];
    }
    return YES;
}
 
- (void) login
{
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:indicator];
    [indicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
    [[AuthenticationManager sharedInstance]
     authenticateWithUsername:self.usernameField.text
     andPassword:self.passwordField.text
     shouldRemember:YES
     withCompletionBlock:nil
     andErrorBlock:^(NSError *error) {
         [indicator removeFromSuperview];
         [self.view setUserInteractionEnabled:YES];
         if(error.code == ErrorCodeUsernameOrPasswordIsWrong)
         {
             [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Username or password is wrong please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
         }
     }];
}


@end
