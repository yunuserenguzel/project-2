//
//  SNCSearchViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/22/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSearchViewController.h"
#import "SNCPersonTableCell.h"
#import "SNCAPIManager.h"
#import "SonicArray.h"
#import "SonicCollectionViewCell.h"
#import "SNCProfileViewController.h"
#import "SNCSonicViewController.h"
#import "Configurations.h"
#import "SonicCollectionViewFlowLayout.h"


typedef enum SearchContentType {
    SearchContentTypeSonics = 111,
    SearchContentTypeUsers = 222
}
SearchContentType;

@interface SNCSearchViewController ()

@property NSArray* users;
@property SonicArray* sonics;
@property SonicArray* populerSonics;

@property UIActivityIndicatorView* centerSonicActivtyIndicator;

@property (nonatomic) SearchContentType searchContentType;

@end

@implementation SNCSearchViewController
{
    UIActivityIndicatorView* activityView;
    User* selectedUser;
    Sonic* selectedSonic;
}
- (CGRect) segmentedControlFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 6;
    return CGRectMake(70.0, y, 160.0, 33.0);
}
- (CGRect) searchFieldFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}
- (CGRect) contentRect
{
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height;
    return CGRectMake(0.0, 0.0, 320.0, h);
}
- (CGRect) centerActivityIndicatorFrame
{
    return CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - 33.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setSearchContentType:(SearchContentType)searchContentType
{
    if(_searchContentType != searchContentType){
        _searchContentType = searchContentType;
        [self.searchBar removeFromSuperview];
        [self.userTableView reloadData];
        [self.sonicsCollectionView reloadData];
        if(self.searchContentType == SearchContentTypeUsers){
            [self.userTableView.tableHeaderView addSubview:self.searchBar];
            [self.userTableView setHidden:NO];
            [self.sonicsCollectionView setHidden:YES];
        } else {
            [self.sonicsCollectionView addSubview:self.searchBar];
            [self.sonicsCollectionView setHidden:NO];
            [self.userTableView setHidden:YES];
        }
    }
}

- (void) segmentControlValueChanged
{
    if(self.segmentControl.selectedSegmentIndex == 0){
        self.searchContentType = SearchContentTypeSonics;
    } else {
        self.searchContentType = SearchContentTypeUsers;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.userTableView deselectRowAtIndexPath:[self.userTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scrollToTop)
     name:NotificationTabbarItemReSelected
     object:[NSNumber numberWithInt:1]];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:MainThemeColor];
    
    [self initSegmentControl];
    [self initUserTableView];
    [self initSonicCollectionView];
    [self initSearchInstruments];
    [self initializeCenterActivityIndicator];
    [self setSearchContentType:SearchContentTypeSonics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clean) name:NotificationUserLoggedOut object:nil];

    [self getPopulerSonics];
}

- (void) initializeCenterActivityIndicator
{
    self.centerSonicActivtyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.centerSonicActivtyIndicator setFrame:[self centerActivityIndicatorFrame]];
    [self.sonicsCollectionView addSubview:self.centerSonicActivtyIndicator];
}

- (void) scrollToTop
{
    [self.sonicsCollectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.userTableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

- (void) clean
{
    self.searchBar.text = @"";
    [self.view endEditing:YES];
    self.sonics = nil;
    self.users = nil;
    [self.userTableView reloadData];
    [self.sonicsCollectionView reloadData];
}

- (void) initSegmentControl
{
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Sonics",@"Users"]];
    [self.segmentControl setFrame:[self segmentedControlFrame]];
    [self.segmentControl setSelectedSegmentIndex:0];
    self.navigationItem.titleView = self.segmentControl;
    [self.segmentControl sizeToFit];
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void) initUserTableView
{
    self.userTableView = [[UITableView alloc] initWithFrame:[self contentRect] style:UITableViewStylePlain];
    [self.view addSubview:self.userTableView];
    [self.userTableView registerClass:[SNCPersonFollowableTableCell class] forCellReuseIdentifier:@"PersonCell"];
    [self.userTableView setTableHeaderView:[[UIView alloc] initWithFrame:[self searchFieldFrame]]];
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    [self.userTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.userTableView setUserInteractionEnabled:YES];
}

- (void) initSonicCollectionView
{
    UICollectionViewFlowLayout* layout = [[SonicCollectionViewFlowLayout alloc] init];
    [layout setHeaderReferenceSize:CGSizeMake(320.0, 44.0)];
    self.sonicsCollectionView = [[UICollectionView alloc] initWithFrame:[self contentRect] collectionViewLayout:layout];
    [self.view addSubview:self.sonicsCollectionView];
    [self.sonicsCollectionView setDataSource:self];
    [self.sonicsCollectionView setDelegate:self];
    [self.sonicsCollectionView setAlwaysBounceVertical:YES];
    [self.sonicsCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.sonicsCollectionView registerClass:[SonicCollectionViewCell class] forCellWithReuseIdentifier:@"SonicCell"];
}

- (void) initSearchInstruments
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:[self searchFieldFrame]];
    [self.searchBar setDelegate:self];
    [self.searchBar setBarTintColor:CellSpacingGrayColor];
    [self.searchBar.layer setBorderColor:CellSpacingGrayColor.CGColor];
    [self.searchBar.layer setBorderWidth:1.0];
    self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self clean];
}

- (void) getPopulerSonics
{
    [self.centerSonicActivtyIndicator startAnimating];
    [SNCAPIManager getPopulerSonicsWithCompletionBlock:^(NSArray *sonics) {
        self.populerSonics = [[SonicArray alloc] init];
        [self.populerSonics importSonicsWithArray:sonics];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sonicsCollectionView reloadData];
            [self.centerSonicActivtyIndicator stopAnimating];
        });
        
    } andErrorBlock:^(NSError *error) {
        [self.centerSonicActivtyIndicator stopAnimating];
    }];
    
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    if(activityView == nil){
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityView setColor:[UIColor whiteColor]];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView startAnimating];
    if(self.searchContentType == SearchContentTypeUsers){
        [SNCAPIManager getUsersWithSearchQuery:self.searchBar.text withCompletionBlock:^(NSArray *users) {
            [activityView stopAnimating];
            self.navigationItem.rightBarButtonItem = nil;
            self.users = users;
            [self.userTableView reloadData];
        } andErrorBlock:^(NSError *error) {
            [activityView stopAnimating];
            self.navigationItem.rightBarButtonItem = nil;
        }];
    }else{
        [SNCAPIManager getSonicsWithSearchQuery:self.searchBar.text withCompletionBlock:^(NSArray *sonics) {
            [activityView stopAnimating];
            self.navigationItem.rightBarButtonItem = nil;
            self.sonics = [[SonicArray alloc] init];
            [self.sonics importSonicsWithArray:sonics];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sonicsCollectionView reloadData];
            });
        } andErrorBlock:^(NSError *error) {
            [activityView stopAnimating];
            self.navigationItem.rightBarButtonItem = nil;
        }];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SonicCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SonicCell" forIndexPath:indexPath];
    [cell setUserInteractionEnabled:YES];
    Sonic* sonic;
    if(self.sonics == nil)
    {
        sonic = [self.populerSonics objectAtIndex:indexPath.row];
    }
    else
    {
        sonic = [self.sonics objectAtIndex:indexPath.row];
    }
    [cell setSonic:sonic];
    return cell;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sonics ? self.sonics.count : (self.populerSonics ? self.populerSonics.count : 0);
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SonicCollectionViewCell* cell = (SonicCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    selectedSonic = cell.sonic;
    [self performSegueWithIdentifier:SearchToSonicSegue sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCPersonFollowableTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"];
    [cell setUser:[self.users objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users ? self.users.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedUser = [self.users objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SearchToProfileSegue sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController class] == [SNCProfileViewController class]){
        SNCProfileViewController* profile = segue.destinationViewController;
        [profile setUser:selectedUser];
    } else {
        SNCSonicViewController* sonicViewController = segue.destinationViewController;
        [sonicViewController setSonic:selectedSonic];
    }
}

@end
