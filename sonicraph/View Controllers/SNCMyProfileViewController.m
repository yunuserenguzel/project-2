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
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshForNewLogin:)
     name:NotificationUserLoggedIn
     object:nil];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    [self.profileHeaderView.likedSonicsButton setHidden:NO];
    
    [self.profileHeaderView.followButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    [self.profileHeaderView.followButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.profileHeaderView.followButton addTarget:self action:@selector(openEditProfile) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newSonicArrived:)
     name:NotificationNewSonicCreated
     object:nil];
}

- (void) newSonicArrived:(NSNotification*)notification
{
    [self.sonics addObject:notification.object];
    [[self sonicCollectionView] reloadData];
    [[self sonicListTableView] reloadData];
}

- (void) openEditProfile
{
    [self performSegueWithIdentifier:MyProfileToEditProfileSegue sender:self];
}

- (void) openSettings
{
    [self performSegueWithIdentifier:ProfileToSettingsSegue sender:self];
}

- (void) refreshForNewLogin:(NSNotification*)notification
{
    [self setUser:[[AuthenticationManager sharedInstance] authenticatedUser]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
