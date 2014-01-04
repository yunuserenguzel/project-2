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
    [self initializeSonicCollectionView];
    [self initializeSonicListTableView];

    
    self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:[self profileHeaderViewFrame]];
    [self.view addSubview:self.profileHeaderView];
    [self.profileHeaderView.gridViewButton addTarget:self action:@selector(setGridViewModeOn) forControlEvents:UIControlEventTouchUpInside];
    [self.profileHeaderView.listViewButton addTarget:self action:@selector(setListViewModeOn) forControlEvents:UIControlEventTouchUpInside];
}

//- (void) setUser:(UserManagedObject *)user
//{
//    _user = user;
//    [SNCAPIManager getUserSonics:self.user withCompletionBlock:^(NSArray *sonics) {
//        
//    }];
//    
//    [SNCAPIManager getUserSonics:<#(User *)#> saveToDatabase:<#(BOOL)#> withCompletionBlock:<#^(NSArray *sonics)completionBlock#> andErrorBlock:<#^(NSError *error)errorBlock#>]
//}

- (void) setGridViewModeOn
{
    [self.sonicCollectionView setHidden:YES];
    [self.sonicListTableView setHidden:NO];
}

- (void) setListViewModeOn
{
    [self.sonicCollectionView setHidden:NO];
    [self.sonicListTableView setHidden:YES];
}

- (void) initializeSonicCollectionView
{
    
    self.sonicCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.sonicCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.sonicCollectionViewFlowLayout setItemSize:CGSizeMake(160.0, 160.0)];
    [self.sonicCollectionViewFlowLayout setMinimumLineSpacing:1.0];
    [self.sonicCollectionViewFlowLayout setMinimumInteritemSpacing:0.0];
    self.sonicCollectionView = [[UICollectionView alloc] initWithFrame:[self sonicCollectionViewFrame] collectionViewLayout:self.sonicCollectionViewFlowLayout];
    [self.sonicCollectionView setDataSource:self];
    [self.sonicCollectionView setDelegate:self];
    [self.sonicCollectionView setContentInset:UIEdgeInsetsMake([self profileHeaderViewFrame].size.height, 0.0, 0.0, 0.0)];
    [self.sonicCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCHomeTableCell* cell = [tableView dequeueReusableCellWithIdentifier:HomeTableCellIdentifier];
    [cell setSonic:[[self sonics] objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightForHomeCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    NSLog(@"topOffset: %f",topOffset);
    if(topOffset < scrollView.contentInset.top){
        CGRect frame = [self profileHeaderViewFrame];
        frame.origin.y -= topOffset;
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
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NotificationSonicsAreLoaded
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:nil
                                                  object:nil];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sonicManagedObject getImage]];
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height);
    [imageView setUserInteractionEnabled:NO];
    NSURL*  url = [NSURL URLWithString:[sonic sonicUrl]];
    [SNCAPIManager getSonic:url withSonicBlock:^(SonicData *sonic, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = sonic.image;
        });
    }];
    
    [cell addSubview:imageView];
    return cell;
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
    NSLog(@"indexPath.row: %d",indexPath.row);
    selectedSonic = [self.sonics objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:ProfileToPreviewSegue sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:ProfileToPreviewSegue]){
        SNCSonicViewController* preview = segue.destinationViewController;
        [preview setSonic:selectedSonic];
    }
}

@end
