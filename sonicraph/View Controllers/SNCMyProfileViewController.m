//
//  SNCMyProfileViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/7/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCMyProfileViewController.h"
#import "AuthenticationManager.h"
@interface SNCMyProfileViewController ()

@end

@implementation SNCMyProfileViewController

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
    [self setUser:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForNewLogin:) name:NotificationUserLoggedIn object:nil];
}

- (void) refreshForNewLogin:(NSNotification*)notification
{
    [self setUser:[[AuthenticationManager sharedInstance] authenticatedUser]];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
