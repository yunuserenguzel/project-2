//
//  SNCProfileViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCProfileViewController.h"
#import "SNCAPIManager.h"
#import "SNCEditViewController.h"
#import "SonicData.h"
#import "Configurations.h"
#import "SNCSonicViewController.h"
#import "SNCHomeTableCell.h"
#import "SonicCollectionViewCell.h"
#import "SNCFollowerFollowingViewController.h"
#import "SNCAppDelegate.h"
#import "UIButton+StateProperties.h"
#import "AuthenticationManager.h"
@interface SNCProfileViewController ()


@property SonicArray* likedSonics;

@end

@implementation SNCProfileViewController
{
    Sonic* selectedSonic;
    User* userToBeOpen;
    BOOL showLikedSonics;
    BOOL shouldShowFollowers;
    BOOL isLoadingFromServer;
}

- (CGRect) profileHeaderViewFrame
{
    return CGRectMake(0.0, -ProfileHeaderViewHeight, 320.0, ProfileHeaderViewHeight);
}

- (CGRect) scrollContentHeaderFrame
{
    CGRect frame = [self profileHeaderViewFrame];
    frame.origin = CGPointZero;
    return frame;
}

- (CGRect) sonicCollectionViewFrame
{
    CGFloat y =  [self scrollContentHeaderFrame].origin.y;
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    return CGRectMake(0.0, y, 320.0, h);
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
    self.sonics = [[SonicArray alloc] init];
    
    self.navigationItem.title = @"Profile";
    [self initializeSonicCollectionView];
    [self initializeSonicListTableView];
    [self initializeHeaderView];
    
    [self refresh];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshUser:)
     name:NotificationUpdateViewForUser
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userLoggedOut:)
     name:NotificationUserLoggedOut
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(removeSonic:)
     name:NotificationSonicDeleted
     object:nil];
    
    [self configureViews];
    
}

- (void) initializeHeaderView
{
    self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:[self profileHeaderViewFrame]];
    [self.profileHeaderView.gridViewButton addTarget:self action:@selector(setGridViewModeOn) forControlEvents:UIControlEventTouchUpInside];
    [self.profileHeaderView.listViewButton addTarget:self action:@selector(setListViewModeOn) forControlEvents:UIControlEventTouchUpInside];
    [self.profileHeaderView.likedSonicsButton addTarget:self action:@selector(showLikedSonics) forControlEvents:UIControlEventTouchUpInside];
    [self setGridViewModeOn];
    
    UIGestureRecognizer* tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.profileHeaderView.followersLabel addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.profileHeaderView.followingsLabel addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.profileHeaderView.numberOfFollowersLabel addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.profileHeaderView.numberOfFollowingsLabel addGestureRecognizer:tapGestureRecognizer];
    
}

- (void) openEditProfile
{
    [self performSegueWithIdentifier:EditProfileSegue sender:self];
}
-(void) removeSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonics deleteSonicWithId:sonic.sonicId]){
        [self refresh];
    }
}

- (void) userLoggedOut:(NSNotification*)notification
{
    self.sonics = [[SonicArray alloc] init];
}
- (void)setUser:(User *)user
{
    _user = user;
    [self configureViews];
    isLoadingFromServer = YES;
    [SNCAPIManager getUserSonics:user before:nil withCompletionBlock:^(NSArray *sonics) {
        [self.sonics importSonicsWithArray:sonics];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refresh];
            isLoadingFromServer = NO;
        });
    } andErrorBlock:^(NSError *error) {
        isLoadingFromServer = NO;
    }];
}

- (void) configureViews
{
    self.profileHeaderView.userProfileImageView.image = SonicPlaceholderImage;
    [self.user getThumbnailProfileImageWithCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileHeaderView.userProfileImageView.image = (UIImage*) object;
        });
    }];
    self.profileHeaderView.usernamelabel.text = [NSString stringWithFormat:@"@%@",self.user.username];
    self.profileHeaderView.fullnameLabel.text = self.user.fullName;
    self.profileHeaderView.locationLabel.text = self.user.location;
    self.profileHeaderView.websiteLabel.text = self.user.website;
    self.profileHeaderView.numberOfSonicsLabel.text = [NSString stringWithFormat:@"%d",self.user.sonicCount];
    self.profileHeaderView.numberOfFollowersLabel.text = [NSString stringWithFormat:@"%d",self.user.followerCount];
    self.profileHeaderView.numberOfFollowingsLabel.text = [NSString stringWithFormat:@"%d",self.user.followingCount];
    
    [self configureFollowButton];
}

- (void) configureFollowButton
{
    [self.profileHeaderView.followButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    if([self.user.userId isEqualToString:[[[AuthenticationManager sharedInstance] authenticatedUser] userId]])
    {
        [self.profileHeaderView.followButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
        [self.profileHeaderView.followButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.profileHeaderView.followButton setBackgroundImageWithColor:rgb(245.0, 245.0, 245.0) forState:UIControlStateNormal];
        [self.profileHeaderView.followButton.layer setBorderColor:rgb(245.0, 245.0, 245.0).CGColor];
        [self.profileHeaderView.followButton addTarget:self action:@selector(openEditProfile) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        if([self.user isBeingFollowed])
        {
            [self.profileHeaderView.followButton setSelected:YES];
            [self.profileHeaderView.followButton addTarget:self action:@selector(unfollow) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [self.profileHeaderView.followButton setSelected:NO];
            [self.profileHeaderView.followButton addTarget:self action:@selector(follow) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self.profileHeaderView.followButton setEnabled:YES];
}

- (void) follow
{
    [self.profileHeaderView.followButton setEnabled:NO];
    [SNCAPIManager followUser:self.user withCompletionBlock:^(BOOL successful) {
        self.user.isBeingFollowed = YES;
        self.user.followerCount++;
        [self configureViews];
    } andErrorBlock:^(NSError *error) {
        [self.profileHeaderView.followButton setEnabled:YES];
    }];
}

- (void) unfollow
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:self.user.fullName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles: nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void) confirmUnfollow
{
    [self.profileHeaderView.followButton setEnabled:NO];
    [SNCAPIManager unfollowUser:self.user withCompletionBlock:^(BOOL successful) {
        self.user.isBeingFollowed = NO;
        self.user.followerCount--;
        [self configureViews];
    } andErrorBlock:^(NSError *error) {
        [self.profileHeaderView.followButton setEnabled:YES];
    }];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self confirmUnfollow];
    }
    else
    {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    
}


- (void) tapGesture:(UIGestureRecognizer*)tapGesture
{
    
    if(tapGesture.view == self.profileHeaderView.followersLabel || tapGesture.view == self.profileHeaderView.numberOfFollowersLabel){
        shouldShowFollowers = YES;
    }
    else if (tapGesture.view == self.profileHeaderView.followingsLabel || tapGesture.view == self.profileHeaderView.numberOfFollowingsLabel){
        shouldShowFollowers = NO;
    }
    [self performSegueWithIdentifier:ProfileToFollowerFollowingSegue sender:self];
}

- (void) initializeSonicCollectionView
{
    self.sonicCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.sonicCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.sonicCollectionViewFlowLayout setItemSize:CGSizeMake(106.0, 106.0)];
    [self.sonicCollectionViewFlowLayout setMinimumLineSpacing:1.0];
    [self.sonicCollectionViewFlowLayout setMinimumInteritemSpacing:1.0];
    self.sonicCollectionView = [[UICollectionView alloc] initWithFrame:[self sonicCollectionViewFrame] collectionViewLayout:self.sonicCollectionViewFlowLayout];
    [self.sonicCollectionView setDataSource:self];
    [self.sonicCollectionView setDelegate:self];
    [self.sonicCollectionView setContentInset:UIEdgeInsetsMake([self profileHeaderViewFrame].size.height, 0.0, 0.0, 0.0)];
    [self.sonicCollectionView registerClass:[SonicCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.sonicCollectionView setBackgroundColor:[UIColor lightGrayColor]];
    [self.sonicCollectionView setShowsVerticalScrollIndicator:NO];

	[self.view addSubview:self.sonicCollectionView];
    
    [self.sonicCollectionView setHidden:YES];
}

- (void) initializeSonicListTableView
{
    self.sonicListTableView = [[UITableView alloc] initWithFrame:[self sonicCollectionViewFrame] style:UITableViewStylePlain];
    [self.view addSubview:self.sonicListTableView];
    [self.sonicListTableView setDataSource:self];
    [self.sonicListTableView setDelegate:self];
    [self.sonicListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.sonicListTableView setContentInset:UIEdgeInsetsMake([self profileHeaderViewFrame].size.height, 0.0, 0.0, 0.0)];
    [self.sonicListTableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
    [self.sonicListTableView setHidden:YES];
}

- (void) setListViewModeOn
{
    [self.profileHeaderView.listViewButton setSelected:YES];
    [self.profileHeaderView.gridViewButton setSelected:NO];
    [self.profileHeaderView.likedSonicsButton setSelected:NO];
    [self.sonicListTableView addSubview:self.profileHeaderView];
    
    if([self.sonicListTableView isHidden] == YES){
        [self.sonicCollectionView setHidden:YES];
        [self.sonicListTableView setHidden:NO];
    }
    [self.sonicListTableView reloadData];
}

- (void) setGridViewModeOn
{
    [self.profileHeaderView.listViewButton setSelected:NO];
    [self.profileHeaderView.gridViewButton setSelected:YES];
    [self.profileHeaderView.likedSonicsButton setSelected:NO];
    [self.sonicCollectionView addSubview:self.profileHeaderView];
    showLikedSonics = NO;
    if([self.sonicCollectionView isHidden] == YES){
        [self.sonicCollectionView setHidden:NO];
        [self.sonicListTableView setHidden:YES];
    }
    [self.sonicCollectionView reloadData];
}
- (void) showLikedSonics
{
    [self setGridViewModeOn];
    [self.profileHeaderView.listViewButton setSelected:NO];
    [self.profileHeaderView.gridViewButton setSelected:NO];
    [self.profileHeaderView.likedSonicsButton setSelected:YES];
    showLikedSonics = YES;
    if(self.likedSonics == nil) {
        self.likedSonics = [[SonicArray alloc] init];
        [SNCAPIManager getSonicsILikedwithCompletionBlock:^(NSArray *sonics) {
            [self.likedSonics importSonicsWithArray:sonics];
            [self.sonicCollectionView reloadData];
        } andErrorBlock:nil];
    }
    [self.sonicCollectionView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sonics ? self.sonics.count : 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)sonic:(Sonic *)sonic actionFired:(SNCHomeTableCellActionType)actionType
{
    selectedSonic = sonic;
    if(actionType == SNCHomeTableCellActionTypeComment){
        [self performSegueWithIdentifier:ProfileToPreviewSegue sender:self];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCHomeTableCell* cell = [tableView dequeueReusableCellWithIdentifier:HomeTableCellIdentifier];
    if(cell.sonic != [[self sonics] objectAtIndex:indexPath.row]){
        [cell setDelegate:self];
        [cell setSonic:[[self sonics] objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightForHomeCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!isLoadingFromServer && scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height) < 20.0)
    {
        isLoadingFromServer = YES;
        [SNCAPIManager getUserSonics:self.user before:self.sonics.lastObject withCompletionBlock:^(NSArray *sonics) {
            [self.sonics importSonicsWithArray:sonics];
            if(sonics.count > 0)
            {
                isLoadingFromServer = NO;
            }
            [self refresh];
        } andErrorBlock:^(NSError *error) {
            isLoadingFromServer = NO;
            [self refresh];
        }];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    
}


- (void) refresh
{
    [self.sonicCollectionView reloadData];
    [self.sonicListTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SonicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Sonic* sonic;
    if(showLikedSonics){
        sonic = [self.likedSonics objectAtIndex:indexPath.row];
    } else {
        sonic = [self.sonics objectAtIndex:indexPath.row];
    }
    [cell setSonic:sonic];
    return cell;
}

- (void) refreshUser:(NSNotification*) notification
{
    User* user = notification.object;
    if(self.user == user){
        [self configureViews];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.sonics && !showLikedSonics)
        return self.sonics.count;
    else if(self.likedSonics && showLikedSonics)
        return self.likedSonics.count;
    else
        return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(showLikedSonics){
        selectedSonic = [self.likedSonics objectAtIndex:indexPath.row];
    } else {
        selectedSonic = [self.sonics objectAtIndex:indexPath.row];
    }
    if(selectedSonic.isResonic){
        selectedSonic = selectedSonic.originalSonic;
    }
    [self performSegueWithIdentifier:ProfileToPreviewSegue sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString* segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:ProfileToPreviewSegue]){
        SNCSonicViewController* preview = segue.destinationViewController;
        [preview setSonic:selectedSonic];
    }else if([segueIdentifier isEqualToString:ProfileToFollowerFollowingSegue]){
        SNCFollowerFollowingViewController* follow = segue.destinationViewController;
        [follow setUser:self.user];
        [follow setShouldShowFollowers:shouldShowFollowers];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:nil
     object:nil];
}

- (void)openProfileForUser:(User *)user
{
    if(user != self.user){
    }
}

@end
