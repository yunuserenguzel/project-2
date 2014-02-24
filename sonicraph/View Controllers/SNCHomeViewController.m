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
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    indexOfCellToBeIncreased = -1;
    [self initTableView];
    
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
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            SNCAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
            [appDelegate sessionStateChanged:session state:state error:error];
            
        }];
    }

}
- (void) initTableView
{

    self.tableView.contentInset = [self edgeInsetsForScrollContent];
    [self.tableView setBackgroundColor:CellSpacingGrayColor];
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

- (void) initRefreshController
{
    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.tableView insertSubview:self.refreshControl atIndex:0];
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
}

- (void) newSonicArrived:(NSNotification*)notification
{
    [self.sonics addObject:notification.object];
    [self refresh];
}



- (void) refreshFromServer
{
    isLoadingFromServer = YES;
//    Sonic* lastSonic = self.sonics.count > 0 ? [self.sonics objectAtIndex:0] : nil;
    [SNCAPIManager getSonicsAfter:nil withCompletionBlock:^(NSArray *sonics) {
        self.sonics = [[SonicArray alloc] init];
        [self.sonics importSonicsWithArray:sonics];
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
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [cellWiningTheCenter cellLostCenterOfTableView];
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

- (void) autoPlay:(UIScrollView*)scrollView
{
    CGFloat x = self.tableView.contentOffset.x;
    CGFloat y = self.tableView.contentOffset.y + self.tableView.frame.size.height * 0.5;
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = HeightForHomeCell * 0.4;
    y -= height * 0.5;
    CGRect rect = CGRectMake(x, y, width, height);
    
    NSArray* indexPaths = [self.tableView indexPathsForRowsInRect:rect];
    if([indexPaths count] == 1){
        cellWiningTheCenter = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cellWiningTheCenter cellWonCenterOfTableView];
        });

    }
    else {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL *stop) {
            SNCHomeTableCell* cell = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell cellLostCenterOfTableView];
            });
        }];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [cellWiningTheCenter cellLostCenterOfTableView];
    if(!isLoadingFromServer && scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height) < 20.0)
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self autoPlay:scrollView];
        });
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self autoPlay:scrollView];
    });
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
