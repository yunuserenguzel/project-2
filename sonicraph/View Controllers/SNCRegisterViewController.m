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

@interface SNCRegisterViewController ()

@end

@implementation SNCRegisterViewController

- (CGRect) scrollViewFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    return CGRectMake(0.0, y , 320.0, self.view.frame.size.height - y);
}

- (CGRect) emailFieldFrame
{
    return CGRectMake(10.0, 20.0, 300.0, 50.0);
}

- (CGRect) usernameFieldFrame
{
    return CGRectMake(10.0, 90.0, 300.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(10.0, 160.0, 300.0, 50.0);
}

- (CGRect) registerButtonFrame
{
    return CGRectMake(10.0, 230.0, 300.0, 50.0);
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:[self scrollViewFrame]];
    [self.view addSubview:self.scrollView];
    
    self.emailField = [[UITextField alloc] initWithFrame:[self emailFieldFrame]];
    self.usernameField = [[UITextField alloc] initWithFrame:[self usernameFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.emailField setPlaceholder:@"e-mail"];
    [self.usernameField setPlaceholder:@"username"];
    [self.passwordField setPlaceholder:@"password"];
    
//    [self.emailField setText:@"test@test.com"];
//    [self.usernameField setText:@"test1"];
//    [self.passwordField setText:@"12345"];
    
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.passwordField setSecureTextEntry:YES];
    
    [@[self.emailField, self.usernameField, self.passwordField] enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
        textField.layer.borderColor = NavigationBarBlueColor.CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius = 4.0f;
        [textField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)]];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        textField.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:textField];
    }];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.registerButton.frame = [self registerButtonFrame];
    [self.registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.registerButton];
    
	// Do any additional setup after loading the view.
}

- (void) registerUser
{
    
    [[AuthenticationManager sharedInstance] registerUserWithEmail:self.emailField.text andUsername:self.usernameField.text andPassword:self.passwordField.text andCompletionBlock:^(User *user, NSString *token) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    } andErrorBlock:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
