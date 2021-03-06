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
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [barButtonItem setImageInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 10.0)];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    [self.profileHeaderView.likedSonicsButton setHidden:NO];
    [self setUser:[[AuthenticationManager sharedInstance] authenticatedUser]];
    
    
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
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshForNewLogin:)
     name:NotificationUserLoggedIn
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scrollToTop)
     name:NotificationTabbarItemReSelected
     object:[NSNumber numberWithInt:4]];
}


- (void) userChanged:(NSNotification*)notification
{
    User* user = notification.object;
    if(self.user == user)
    {
        [self setUser:user];
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
    [self.navigationController popToRootViewControllerAnimated:NO];
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
