//
//  SNCHomeViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/12/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeViewController.h"
#import "TypeDefs.h"
#import "Sonic.h"
#import "Configurations.h"
#import "SNCAPIManager.h"
#import "SNCSonicViewController.h"
#import "SonicArray.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SNCAppDelegate.h"

@interface SNCHomeViewController ()

@property SonicArray* sonics;

@property UIActivityIndicatorView* bottomActivityIndicator;

@property UILabel* oops;

@end

@implementation SNCHomeViewController
{
    SNCHomeTableCell* cellWiningTheCenter;
    NSInteger indexOfCellToBeIncreased;
    Sonic* sonicToBeViewed;
    User* userToBeOpen;
    SonicViewControllerInitiationType sonicViewControllerInitiationType;
    BOOL isLoadingFromServer;
}

- (CGRect) tableFooterViewRect
{
    return CGRectMake(0.0, 0.0, 320.0, 11.0);
}

- (CGRect) oopsFrame
{
    return CGRectMake(0.0, self.view.frame.size.height*0.5 - 160.0, 320.0, 160.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    indexOfCellToBeIncreased = -1;
    [self initTableView];
    [self initOops];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar_logo.png"]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newSonicArrived:)
     name:NotificationNewSonicCreated
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(removeSonic:)
     name:NotificationSonicDeleted
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userLoggedOut:)
     name:NotificationUserLoggedOut
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshFromServer)
     name:NotificationUserLoggedIn
     object:nil];
    
    self.sonics  = [[SonicArray alloc] init];
    [self initRefreshController];
    [self refreshFromServer];
    
    
}
- (void) initTableView
{

    self.tableView.contentInset = [self edgeInsetsForScrollContent];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setScrollsToTop:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:[self tableFooterViewRect]]];
    [self.tableView setTableHeaderView:[UIView new]];
    self.bottomActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.bottomActivityIndicator.frame = [self tableFooterViewRect];
    [self.tableView.tableFooterView addSubview:self.bottomActivityIndicator];
    
}

- (void) initOops
{
    self.oops = [[UILabel alloc] initWithFrame:[self oopsFrame]];
    self.oops.textColor = TabbarNonActiveButtonTintColor;
    self.oops.textAlignment = NSTextAlignmentCenter;
    self.oops.font = [UIFont systemFontOfSize:14.0];
    self.oops.numberOfLines = 0;
    [self.oops setHidden:YES];
    self.oops.text = @"Oops!\n\nYou don't have any Sonic yet\nBe creative & inspire people\n\n Follow and get Followers\nit's fun with friends";
    [self.view addSubview:self.oops];
}

- (void) initRefreshController
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFromServer) forControlEvents:UIControlEventValueChanged];
}

- (void) removeSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonics deleteSonicWithId:sonic.sonicId]){
        [self refresh];
    }
}


- (void) userLoggedOut:(NSNotification*)notification
{
    self.sonics = [[SonicArray alloc] init];
    [self refresh];
}

- (void) newSonicArrived:(NSNotification*)notification
{
    [self.sonics addObject:notification.object];
    [self refresh];
}

- (void) refreshFromServer
{
    isLoadingFromServer = YES;
    [SNCAPIManager getSonicsAfter:nil withCompletionBlock:^(NSArray *sonics) {
        self.sonics = [[SonicArray alloc] init];
        [self.sonics importSonicsWithArray:sonics];
        [self.oops setHidden:(self.sonics.count > 0)];
        [self refresh];
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
    } andErrorBlock:^(NSError *error) {
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
    }];
}

- (void)sonic:(Sonic *)sonic actionFired:(SNCHomeTableCellActionType)actionType
{
    sonicToBeViewed = sonic;
    switch (actionType) {
        case SNCHomeTableCellActionTypeComment:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeCommentWrite;
            break;
        case SNCHomeTableCellActionTypeOpenComments:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeCommentRead;
            break;
        case SNCHomeTableCellActionTypeOpenLikes:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeLikeRead;
            break;
        case SNCHomeTableCellActionTypeOpenResonics:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeResonicRead;
            break;
        default:
            break;
    }
    [self performSegueWithIdentifier:ViewSonicSegue sender:self];
}

- (void) refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlaying];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sonics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = HomeTableCellIdentifier;
    SNCHomeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
    if(sonic != cell.sonic){
        [cell setSonic:[self.sonics objectAtIndex:indexPath.row]];
        cell.delegate = self;
    }
    return cell;
}

- (void) stopPlaying
{
    for(SNCHomeTableCell* cell in [self.tableView visibleCells])
    {
        [cell cellLostCenterOfTableView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self stopPlaying];
    if(!isLoadingFromServer && self.sonics.count > 0 && scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height) < 20.0)
    {
        isLoadingFromServer = YES;
        [self.bottomActivityIndicator startAnimating];
        [SNCAPIManager getSonicsBefore:self.sonics.lastObject withCompletionBlock:^(NSArray *sonics) {
            [self.sonics importSonicsWithArray:sonics];
            [self.bottomActivityIndicator stopAnimating];
            if(sonics.count > 0)
            {
                isLoadingFromServer = NO;
            }
            [self refresh];
        } andErrorBlock:^(NSError *error) {
            [self.bottomActivityIndicator stopAnimating];
            isLoadingFromServer = NO;
            [self refresh];
        }];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == indexOfCellToBeIncreased){
        return HeightForHomeCell + 44.0;
    }
    return HeightForHomeCell;
}

- (void) openProfileForUser:(User *)user
{
    userToBeOpen = user;
    [self performSegueWithIdentifier:ViewUserSegue sender:self];
}
- (void)openSonicDetails:(Sonic *)sonic
{
    sonicToBeViewed = sonic;
    sonicViewControllerInitiationType = SonicViewControllerInitiationTypeNone;
    [self performSegueWithIdentifier:ViewSonicSegue sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:ViewSonicSegue]){
        SNCSonicViewController* sonicViewController =  segue.destinationViewController;
        [sonicViewController setSonic:sonicToBeViewed];
        [sonicViewController initiateFor:sonicViewControllerInitiationType];
    }
    else if([segue.identifier isEqualToString:ViewUserSegue]){
        SNCProfileViewController* profile = segue.destinationViewController;
        [profile setUser:userToBeOpen];
    }
}


@end
