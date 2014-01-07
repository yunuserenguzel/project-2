//
//  SNCSettingsViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSettingsViewController.h"
#import "AuthenticationManager.h"
@interface SNCSettingsViewController () <UIAlertViewDelegate>

@end

@implementation SNCSettingsViewController

- (CGRect) logoutButtonFrame
{
    return CGRectMake(0.0, 100.0, 320.0, 44.0);
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
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logoutButton.frame = [self logoutButtonFrame];
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.logoutButton];
	// Do any additional setup after loading the view.
}

- (void) logout
{
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Do you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
    } else {
        [[AuthenticationManager sharedInstance] logout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
