//
//  SNCChangePasswordViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 17/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCChangePasswordViewController.h"
#import "SNCAPIManager.h"
#import "Configurations.h"
#import <QuartzCore/QuartzCore.h>

@interface SNCChangePasswordViewController ()
@property UIBarButtonItem* cancelButton;
@end

@implementation SNCChangePasswordViewController

- (CGRect) oldPasswordFieldFrame
{
    return CGRectMake(-1.0, 50.0, 322.0, 44.0);
}
- (CGRect) passwordFieldFrame
{
    return CGRectMake(-1.0, 120.0, 322.0, 44.0);
}
- (CGRect) saveButtonFrame
{
    return CGRectMake(-1.0, 200.0, 322.0, 44.0);
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
    [self.view setBackgroundColor:CellSpacingGrayColor];
    self.navigationItem.title = @"Change Password";
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 0.0,0.0)];
    [self.scrollView setContentSize:self.view.frame.size];
    
    self.oldPassword = [[UITextField alloc] initWithFrame:[self oldPasswordFieldFrame]];
    [self.oldPassword setPlaceholder:@"Old Password"];
    [self.scrollView addSubview:self.oldPassword];
    
    self.password = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    [self.password setPlaceholder:@"New Password"];
    [self.scrollView addSubview:self.password];
    
    for(UITextField* field in @[self.oldPassword,self.password])
    {
        field.secureTextEntry = YES;
        field.backgroundColor = [UIColor whiteColor];
        field.textAlignment = NSTextAlignmentCenter;
        field.borderStyle = UITextBorderStyleNone;
        field.font = [UIFont boldSystemFontOfSize:16.0];
        field.textColor = PinkColor;
        field.layer.borderColor = CellSpacingLineGrayColor.CGColor;
        field.layer.borderWidth = 1.0;
        field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)];
        field.leftViewMode = UITextFieldViewModeAlways;
        field.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)];
        field.rightViewMode = UITextFieldViewModeAlways;
        field.tintColor = PinkColor;
        [field addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventAllEditingEvents];
    }
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveButton setFrame:[self saveButtonFrame]];
    [self.saveButton setTitle:@"Changing..." forState:UIControlStateSelected];
    [self.saveButton setTitle:@"Change" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:PinkColor forState:UIControlStateNormal];
    [self.saveButton setTitleColor:LightPinkTextColor forState:UIControlStateSelected];
    [self.saveButton setTitleColor:LightPinkTextColor forState:UIControlStateHighlighted];
    [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.scrollView addSubview:self.saveButton];
    [self.saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setEnabled:NO];
}

- (void)textFieldDidChange
{
    [self.cancelButton setTitle:@"Cancel"];
    [self.saveButton setTitle:@"Change" forState:UIControlStateDisabled];
    if(self.oldPassword.text.length > 0 && self.password.text.length > 0)
    {
        [self.saveButton setEnabled:YES];
    }
    else
    {
        [self.saveButton setEnabled:NO];
    }
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) save
{
    [self.saveButton setSelected:YES];
//    [self.saveButton setEnabled:NO];
    [SNCAPIManager
     editProfileWithFields:@{@"old_password" : self.oldPassword.text, @"password" : self.password.text}
     withCompletionBlock:^(User *user, NSString *token) {
         [UIView animateWithDuration:0.5 animations:^{
             [self.oldPassword setText:nil];
             [self.password setText:nil];
             [self.saveButton setSelected:NO];
             [self.saveButton setEnabled:NO];
             [self.saveButton setTitle:@"Changed" forState:UIControlStateDisabled];
             [self.cancelButton setTitle:@"Done"];
         }];
     } andErrorBlock:^(NSError *error) {
         if (error.code == 220) {
             
         }
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
