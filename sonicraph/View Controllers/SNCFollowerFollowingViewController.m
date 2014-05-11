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
#import "SNCProfileViewController.h"
#import "AuthenticationManager.h"

@interface SNCFollowerFollowingViewController ()

@property UIActivityIndicatorView* followersCenterActivityIndicator;
@property UIActivityIndicatorView* followingsCenterActivityIndicator;

@property UILabel* noFollowingsLabel;
@property UILabel* noFollowersLabel;

@end

@implementation SNCFollowerFollowingViewController
{
    NSArray* followers;
    NSArray* followings;
    User* userToBeOpen;
}

- (CGRect) centerActivityIndicatorFrame
{
    return CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height);
}

- (CGRect) segmentedControlFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 6;
    return CGRectMake(70.0, y, 160.0, 33.0);
}

- (CGRect) noLabelFrame
{
//    return CGRectMake(60.0, 0.0, 200.0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height);
    return CGRectMake(0.0, self.view.frame.size.height*0.5 - 160.0, 320.0, 160.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTableView];
    [self initializeSegmentedControl];
    [self initializeActivityIndicators];
    [self initializeNoLabels];
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
    
    [self.segmentedControl setSelectedSegmentIndex:self.shouldShowFollowers? 0 : 1];
    [self segmentChanged:self.segmentedControl];
    [self getDataFromServer];
}

- (void) getDataFromServer
{
    if(![self.refreshControl isRefreshing])
    {
        [self.followersCenterActivityIndicator startAnimating];
    }
    [SNCAPIManager getFollowersOfUser:self.user withCompletionBlock:^(NSArray *users) {
        [self.noFollowersLabel setHidden:(users != nil && users.count > 0)];
        followers = users;
        if(self.shouldShowFollowers)
        {
            [self.tableView reloadData];
        }
        [self.followersCenterActivityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    } andErrorBlock:^(NSError *error) {
        [self.followersCenterActivityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
    
    if(![self.refreshControl isRefreshing])
    {
        [self.followingsCenterActivityIndicator startAnimating];
    }
    [SNCAPIManager getFollowingsOfUser:self.user withCompletionBlock:^(NSArray *users) {
        [self.noFollowingsLabel setHidden:(users != nil && users.count > 0)];
        followings = users;
        if(!self.shouldShowFollowers)
        {
            [self.tableView reloadData];
        }
        [self.followingsCenterActivityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    } andErrorBlock:^(NSError *error) {
        [self.followingsCenterActivityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
}

- (void) initializeTableView
{
//    self.tableView.contentInset = [self edgeInsetsForScrollContent];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.tableView registerClass:[SNCPersonFollowableTableCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setTableFooterView:[UIView new]];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getDataFromServer) forControlEvents:UIControlEventValueChanged];
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

- (void) initializeActivityIndicators
{
    self.followersCenterActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.followingsCenterActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    for (UIActivityIndicatorView* indicator in @[self.followingsCenterActivityIndicator,self.followersCenterActivityIndicator]) {
        indicator.color = MainThemeColor;
        indicator.frame = [self centerActivityIndicatorFrame];
    }
    
    [self.tableView addSubview:self.followersCenterActivityIndicator];
}

- (void) initializeNoLabels
{
    self.noFollowersLabel = [[UILabel alloc] init];
    self. noFollowingsLabel = [[UILabel alloc] init];
    if(self.user == [[AuthenticationManager sharedInstance] authenticatedUser])
    {
        [self.noFollowersLabel setText:@"Uh oh!\n\nYou don't have any followers\n\nInvite your friends \nfrom settings"];
        [self.noFollowingsLabel setText:@"C'mon!\n\nY U NO follow anyone\n\nUse search to find people!"];
    }
    else
    {
        [self.noFollowersLabel setText:[NSString stringWithFormat:@"Uh oh!\n\n%@ does not have followers.", self.user.fullName]];
        [self.noFollowingsLabel setText:[NSString stringWithFormat:@"Uh oh!\n\n%@ does not follow anyone.", self.user.fullName]];
    }

    for (UILabel* label in @[self.noFollowersLabel,self.noFollowingsLabel]) {
        [label setFrame:[self noLabelFrame]];
        [label setNumberOfLines:0];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:15.0]];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setHidden:YES];
        [self.tableView addSubview:label];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
        
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]} range:NSMakeRange(0, 6)];
        label.attributedText = attributedString ;
    }
}

- (void) segmentChanged:(UISegmentedControl*)segmentedControl
{
    if([segmentedControl selectedSegmentIndex] == 0){
        self.shouldShowFollowers = YES;
        [self.tableView addSubview:self.followersCenterActivityIndicator];
        [self.followingsCenterActivityIndicator removeFromSuperview];
        [self.tableView addSubview:self.noFollowersLabel];
        [self.noFollowingsLabel removeFromSuperview];
    } else if([segmentedControl selectedSegmentIndex] == 1){
        self.shouldShowFollowers = NO;
        [self.tableView addSubview:self.followingsCenterActivityIndicator];
        [self.followersCenterActivityIndicator removeFromSuperview];
        [self.tableView addSubview:self.noFollowingsLabel];
        [self.noFollowersLabel removeFromSuperview];
    }
    [[self tableView] reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shouldShowFollowers ? followers.count : followings.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCPersonFollowableTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray* array = self.shouldShowFollowers ? followers : followings;
    [cell setUser:[array objectAtIndex:indexPath.row]];
    [cell setDelegate:self];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PersonTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldShowFollowers) {
        [self openProfileForUser:[followers objectAtIndex:indexPath.row]];
    } else {
        [self openProfileForUser:[followings objectAtIndex:indexPath.row]];
    }
}

- (void)followUser:(User *)user
{
    [self.tableView reloadData];
}

- (void)unfollowUser:(User *)user
{
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openProfileForUser:(User *)user
{
    userToBeOpen = user;
    [self performSegueWithIdentifier:FollowerFollowingToProfileSegue sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:FollowerFollowingToProfileSegue]){
        SNCProfileViewController* profile = segue.destinationViewController;
        [profile setUser:userToBeOpen];
        userToBeOpen = nil;
    }
    
}

@end
