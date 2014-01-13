//
//  SNCFollowerFollowingViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/5/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCFollowerFollowingViewController.h"
#import "SNCAPIManager.h"
#import "Configurations.h"

@interface SNCFollowerFollowingViewController ()

@end

@implementation SNCFollowerFollowingViewController
{
    NSArray* followers;
    NSArray* followings;
    BOOL showFollowers;
}

- (CGRect) tableViewFrame
{
    CGRect frame = self.view.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    frame.size.height -= frame.origin.y;
    return frame;
}

- (CGRect) segmentedControlFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 6;
    return CGRectMake(70.0, y, 180.0, 33.0);
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
    // Do any additional setup after loading the view.
    showFollowers = YES;
    [self initializeTableView];
    [self initializeSegmentedControl];
    
    [self configureViews];
    
}
- (void)setUser:(User *)user
{
    _user = user;
    [self configureViews];
}

- (void) configureViews
{
    if(![self isViewLoaded]) return;
    if(!self.user)return;
    [SNCAPIManager getFollowersOfUser:self.user withCompletionBlock:^(NSArray *users) {
        followers = users;
        [self.tableView reloadData];
    } andErrorBlock:^(NSError *error) {
        
    }];
    [SNCAPIManager getFollowingsOfUser:self.user withCompletionBlock:^(NSArray *users) {
        followings = users;
        [self.tableView reloadData];
    } andErrorBlock:^(NSError *error) {
        
    }];
    
}

- (void) initializeTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:[self tableViewFrame]];
    [self.view addSubview:self.tableView];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SNCPersonFollowableTableCell class] forCellReuseIdentifier:@"Cell"];
}

- (void) initializeSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Followers",@"Followings"]];
    [self.segmentedControl setFrame:[self segmentedControlFrame]];
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl sizeToFit];
    self.navigationItem.titleView = self.segmentedControl;
}

- (void) segmentChanged:(UISegmentedControl*)segmentedControl
{
    if([segmentedControl selectedSegmentIndex] == 0){
        showFollowers = YES;
        
    } else if([segmentedControl selectedSegmentIndex] == 1){
        showFollowers = NO;
    }
    [[self tableView] reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return showFollowers ? followers.count : followings.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCPersonFollowableTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray* array = showFollowers ? followers : followings;
    [cell setUser:[array objectAtIndex:indexPath.row]];
    [cell setDelegate:self];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PersonTableCellHeight;
}

- (void)followUser:(User *)user
{
    user.isBeingFollowed = YES;
    [self.tableView reloadData];
    [SNCAPIManager followUser:user withCompletionBlock:^(BOOL successful) {
        
    } andErrorBlock:^(NSError *error) {
        user.isBeingFollowed = NO;
        [self.tableView reloadData];
    }];
}

- (void)unfollowUser:(User *)user
{
    user.isBeingFollowed = NO;
    [self.tableView reloadData];
    [SNCAPIManager unfollowUser:user withCompletionBlock:^(BOOL successful) {
        
    } andErrorBlock:^(NSError *error) {
        user.isBeingFollowed = YES;
        [self.tableView reloadData];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
