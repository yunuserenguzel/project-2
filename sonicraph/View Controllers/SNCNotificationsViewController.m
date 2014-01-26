//
//  SNCNotificationViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCNotificationsViewController.h"
#import "SNCAPIManager.h"

@interface SNCNotificationsViewController ()
@property NSArray* notifications;
@end

@implementation SNCNotificationsViewController

- (CGRect) tableViewFrame
{
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height;
    return CGRectMake(0.0, 0.0, 320.0, h);
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
    [SNCAPIManager getNotificationsWithCompletionBlock:^(NSArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } andErrorBlock:^(NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [self refreshFromServer];
	// Do any additional setup after loading the view.
}

- (void) initTableView
{
    [self.tableView registerClass:[SNCNotificationCell class] forCellReuseIdentifier:@"NotificationCell"];
    [self initRefreshControl];
}

- (void) initRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor grayColor]];
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

@end
