//
//  SNCRegisterViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCRegisterViewController.h"
#import "Configurations.h"
#import "AuthenticationManager.h"
#import "SNCAPIManager.h"
#import "SNCGoThroughViewController.h"
@interface SNCRegisterViewController ()

@end

@implementation SNCRegisterViewController

- (CGRect) titleLabelFrame
{
    return CGRectMake(0.0, 15.0, 320.0, 50.0);
}
- (CGRect) scrollViewFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    return CGRectMake(0.0, y , 320.0, self.view.frame.size.height - y);
}

- (CGRect) emailFieldFrame
{
    return CGRectMake(00.0, 80.0, 320.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(00.0, 132.0, 320.0, 50.0);
}

- (CGRect) termsLabelFrame
{
    return CGRectMake(10.0, 200.0, 300.0, 50.0);
}

- (CGRect) loginButtonFrame
{
    return CGRectMake(0.0, self.view.frame.size.height - 50.0, 320.0, 50.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setText:@"Sign up"];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:26.0]];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[self scrollViewFrame]];
    [self.view addSubview:self.scrollView];
    
    self.emailField = [[UITextField alloc] initWithFrame:[self emailFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.emailField setPlaceholder:@"Email"];
    [self.passwordField setPlaceholder:@"Password"];
    
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.passwordField setSecureTextEntry:YES];
    
    [self.emailField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
    
    [@[self.emailField,self.passwordField] enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
        UIView* base = textFieldWithBaseAndLabel(textField);
        [textField setDelegate:self];
        [self.view addSubview:base];
    }];

    self.termsLabel = [[UILabel alloc] initWithFrame:[self termsLabelFrame]];
    [self.scrollView addSubview:self.termsLabel];
    self.termsLabel.numberOfLines = 2;
    self.termsLabel.text = @"by signing up \n I agree the Terms of Service";
    [self.termsLabel setFont:[UIFont systemFontOfSize:12.0]];
    self.termsLabel.textColor = [UIColor whiteColor];
    self.termsLabel.textAlignment = NSTextAlignmentCenter;
    [self.termsLabel setUserInteractionEnabled:YES];
    [self.termsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTerms)]];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:@"Already signed up? Log in" forState:UIControlStateNormal];
    [self.loginButton.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.loginButton setFrame:[self loginButtonFrame]];
    [self.scrollView addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(openLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}
- (void) openTerms
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sonicraph.com/terms"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(textField == self.passwordField)
    {
        [self.view endEditing:YES];
        [self registerUser];
    }
    return YES;
}

- (void) openLogin
{
    SNCGoThroughViewController* goThrough = (SNCGoThroughViewController*)self.parentViewController;
    [goThrough showLoginViewController];
}

- (void) closeKeyboard
{
    [self.view endEditing:YES];
}

- (void) registerUser
{
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:indicator];
    [indicator startAnimating];

    [[AuthenticationManager sharedInstance] registerUserWithEmail:self.emailField.text andPassword:self.passwordField.text andCompletionBlock:^(User *user, NSString *token) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    } andErrorBlock:^(NSError *error) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        if(error.code == APIErrorCodeEmailExist)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email address is already taken by another user. Please enter a different email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
        else if(error.code == APIErrorCodeEmailIsNotValid)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is not valid. Please enter a valid email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
