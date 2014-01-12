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
#import "Sonic.h"
#import "Configurations.h"
#import "SNCSonicViewController.h"
#import "SNCHomeTableCell.h"
#import "SonicCollectionViewCell.h"
#import "SNCFollowerFollowingViewController.h"

@interface SNCProfileViewController ()

@property NSArray* sonics;

@end

@implementation SNCProfileViewController
{
    Sonic* selectedSonic;
}

- (CGRect) profileHeaderViewFrame
{
    return CGRectMake(0.0,  self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 320.0, 180.0);
}

- (CGRect) scrollContentHeaderFrame
{
    CGRect frame = [self profileHeaderViewFrame];
    frame.origin = CGPointZero;
    return frame;
}

- (CGRect) sonicCollectionViewFrame
{
    CGFloat y =  [self profileHeaderViewFrame].origin.y;
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height - y;
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
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBarTintColor:NavigationBarBlueColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self initializeSonicCollectionView];
    [self initializeSonicListTableView];

    
    self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:[self profileHeaderViewFrame]];
    [self.view addSubview:self.profileHeaderView];
    [self.profileHeaderView.gridViewButton addTarget:self action:@selector(setGridViewModeOn) forControlEvents:UIControlEventTouchUpInside];
    [self.profileHeaderView.listViewButton addTarget:self action:@selector(setListViewModeOn) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    
    [self refresh];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refresh)
     name:NotificationSonicsAreLoaded
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshUser:)
     name:NotificationUserSaved
     object:nil];
}

- (void)setUser:(User *)user
{
    _user = user;
    [self configureViews];
}

- (void) configureViews
{
    self.profileHeaderView.userProfileImageView.image = SonicPlaceholderImage;
    [SNCAPIManager getImage:[NSURL URLWithString:self.user.profileImageUrl] withCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileHeaderView.userProfileImageView.image = (UIImage*) object;
        });
    }];
    self.profileHeaderView.usernamelabel.text = self.user.username;
    self.profileHeaderView.numberOfSonicsLabel.text = [NSString stringWithFormat:@"%d",self.user.sonicCount];
    self.profileHeaderView.numberOfFollowersLabel.text = [NSString stringWithFormat:@"%d",self.user.followerCount];
    self.profileHeaderView.numberOfFollowingsLabel.text = [NSString stringWithFormat:@"%d",self.user.followingCount];
}

- (void) openSettings
{
    [self performSegueWithIdentifier:ProfileToSettingsSegue sender:self];
}

- (void) tapGesture:(UIGestureRecognizer*)tapGesture
{
    if(tapGesture.view == self.profileHeaderView.followersLabel || tapGesture.view == self.profileHeaderView.numberOfFollowersLabel){
        [self performSegueWithIdentifier:ProfileToFollowerFollowingSegue sender:self];
    }
    else if (tapGesture.view == self.profileHeaderView.followingsLabel || tapGesture.view == self.profileHeaderView.numberOfFollowingsLabel){
        [self performSegueWithIdentifier:ProfileToFollowerFollowingSegue sender:self];
    }
}

- (void) setListViewModeOn
{
    if([self.sonicListTableView isHidden] == YES){
        [self.sonicCollectionView setHidden:YES];
        [self.sonicListTableView setHidden:NO];
        [self.sonicListTableView setContentOffset:self.sonicCollectionView.contentOffset];
        [self scrollViewDidScroll:self.sonicListTableView];
    }
}

- (void) setGridViewModeOn
{
    if([self.sonicCollectionView isHidden] == YES){
        [self.sonicCollectionView setHidden:NO];
        [self.sonicListTableView setHidden:YES];
        [self.sonicCollectionView setContentOffset:self.sonicListTableView.contentOffset];
        [self scrollViewDidScroll:self.sonicCollectionView];
    }
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
    [self.sonicListTableView setHidden:NO];
    [self.sonicListTableView setDataSource:self];
    [self.sonicListTableView setDelegate:self];
    [self.sonicListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.sonicListTableView setContentInset:UIEdgeInsetsMake([self profileHeaderViewFrame].size.height, 0.0, 0.0, 0.0)];
    [self.sonicListTableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sonics ? self.sonics.count : 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightForHomeCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
//    NSLog(@"topOffset: %f",topOffset);
    if(topOffset < scrollView.contentInset.top){
        CGRect frame = [self profileHeaderViewFrame];
        frame.origin.y -= topOffset  ;
        [self.profileHeaderView setFrame:frame];
    } else if ( topOffset <= 0) {
        [self.profileHeaderView setFrame:[self profileHeaderViewFrame]];
    } else {
        CGRect frame = [self profileHeaderViewFrame];
        frame.origin.y -= scrollView.contentInset.top;
        [self.profileHeaderView setFrame:frame];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
}


- (void) refresh
{
    self.sonics = [Sonic getFrom:0 to:20];
    [self.sonicCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SonicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
    [cell setSonic:sonic];
    return cell;
}

- (void) refreshUser:(NSNotification*) notification
{
    User* user = notification.object;
    if([self.user.userId isEqualToString:user.userId]){
        self.user = user;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.sonics)
        return self.sonics.count;
    else
        return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedSonic = [self.sonics objectAtIndex:indexPath.row];
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
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:nil
                                                  object:nil];
}

@end
