//
//  SNCMyProfileViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/7/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCMyProfileViewController.h"
#import "AuthenticationManager.h"
#import "UIButton+StateProperties.h"

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
    self.navigationItem.title = @"My Profile";
    [self setUser:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshForNewLogin:)
     name:NotificationUserLoggedIn
     object:nil];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    [self.profileHeaderView.likedSonicsButton setHidden:NO];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newSonicArrived:)
     name:NotificationNewSonicCreated
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userChanged:)
     name:NotificationUpdateUser
     object:self.user];
}

- (void) userChanged:(NSNotification*)notification
{
    User* user = notification.object;
    if(self.user == user)
    {
        self.user = user;
        [self configureViews];
    }
}

- (void) newSonicArrived:(NSNotification*)notification
{
    [self.sonics addObject:notification.object];
    [[self sonicCollectionView] reloadData];
    [[self sonicListTableView] reloadData];
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
