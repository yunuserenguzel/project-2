//
//  SNCNotificationViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCNotificationsViewController.h"
#import "SNCAPIManager.h"
#import "SNCProfileViewController.h"
#import "SNCSonicViewController.h"

@interface SNCNotificationsViewController ()
@property NSArray* notifications;

@property UIActivityIndicatorView* centerActivityIndicator;
@end

@implementation SNCNotificationsViewController
{
    Notification* selectedNotification;
    BOOL isLoadingFromServer;
}
- (CGRect) tableViewFrame
{
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height;
    return CGRectMake(0.0, 0.0, 320.0, h);
}

- (CGRect) centerActivityIndicatorFrame
{
    return CGRectMake(0.0, 0.0, 320.0, self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - 33.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) refreshFromServer
{
    if(isLoadingFromServer)
    {
        return;
    }
    isLoadingFromServer = YES;
    [self.centerActivityIndicator startAnimating];
    [SNCAPIManager getNotificationsWithCompletionBlock:^(NSArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
        [self.centerActivityIndicator stopAnimating];
    } andErrorBlock:^(NSError *error) {
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
        [self.centerActivityIndicator stopAnimating];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [self refreshFromServer];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(clean)
     name:NotificationUserLoggedOut
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scrollToTop)
     name:NotificationTabbarItemReSelected
     object:[NSNumber numberWithInt:3]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.notifications == nil)
    {
        [self refreshFromServer];
    }
}

- (void) clean
{
    self.notifications = nil;
    [self.tableView reloadData];
}

- (void) initTableView
{
//    self.tableView = [[UITableView alloc] initWithFrame:[self frameForScrollContent]];
    self.tableView.contentInset = [self edgeInsetsForScrollContent];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.tableView registerClass:[SNCNotificationCell class] forCellReuseIdentifier:@"NotificationCell"];
//    [self.view addSubview:self.tableView];
    [self.tableView setTableFooterView:[UIView new]];
    [self initRefreshControl];
    [self initializeCenterActivityIndicator];
    
}

-(void) initializeCenterActivityIndicator
{
    self.centerActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.centerActivityIndicator setFrame:[self centerActivityIndicatorFrame]];
    [self.tableView addSubview:self.centerActivityIndicator];
}

- (void) scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

- (void) initRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self action:@selector(refreshFromServer) forControlEvents:UIControlEventValueChanged];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCNotificationCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    [cell setNotification:[self.notifications objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications ? self.notifications.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NotificationTableCellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedNotification = [self.notifications objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(selectedNotification.notificationType == NotificationTypeFollow)
    {
        [self performSegueWithIdentifier:ViewUserSegue sender:self];
    }
    else if(selectedNotification.notificationType == NotificationTypeLike || selectedNotification.notificationType == NotificationTypeResonic || selectedNotification.notificationType == NotificationTypeComment)
    {
        [self performSegueWithIdentifier:ViewSonicSegue sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(selectedNotification.notificationType == NotificationTypeFollow)
    {
        SNCProfileViewController* profileVC = segue.destinationViewController;
        [profileVC setUser:selectedNotification.byUser];
    }
    else if(selectedNotification.notificationType == NotificationTypeComment)
    {
        SNCSonicViewController* sonicVC = segue.destinationViewController;
        [sonicVC setInitiationType:SonicViewControllerInitiationTypeCommentRead];
        [sonicVC setSonic:selectedNotification.toSonic];
    }
    else if(selectedNotification.notificationType == NotificationTypeLike)
    {
        SNCSonicViewController* sonicVC = segue.destinationViewController;
        [sonicVC setInitiationType:SonicViewControllerInitiationTypeLikeSelected];
        [sonicVC setSonic:selectedNotification.toSonic];
    }
    else if(selectedNotification.notificationType == NotificationTypeResonic)
    {
        SNCSonicViewController* sonicVC = segue.destinationViewController;
        [sonicVC setInitiationType:SonicViewControllerInitiationTypeResonicSelected];
        [sonicVC setSonic:selectedNotification.toSonic];
    }
    
}

@end
