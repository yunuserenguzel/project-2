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

@interface SNCHomeViewController ()

@property NSArray* sonics;

@property UIRefreshControl* refreshControl;

@end

@implementation SNCHomeViewController
{
    SNCHomeTableCell* cellWiningTheCenter;
    NSInteger indexOfCellToBeIncreased;
    Sonic* sonicToBeViewed;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
// 45, 173, 254

- (void)viewDidLoad
{
    [super viewDidLoad];
    indexOfCellToBeIncreased = -1;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:NavigationBarBlueColor];
    
    [self.tableView setBackgroundColor:CellSpacingGrayColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NotificationSonicsAreLoaded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NotificationSonicDeleted
                                               object:nil];
    self.sonics  = @[];
    [self initRefreshController];
    [self refreshFromServer];
}
- (void) initRefreshController
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = self.refreshControl;
    [self.refreshControl addTarget:self action:@selector(refreshFromServer) forControlEvents:UIControlEventValueChanged];
}

- (void) refreshFromServer
{
    Sonic* lastSonic = self.sonics.count > 0 ? [self.sonics objectAtIndex:0] : nil;
    [SNCAPIManager getSonicsAfter:lastSonic withCompletionBlock:^(NSArray *sonics) {
        [self.refreshControl endRefreshing];
    } andErrorBlock:^(NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)sonic:(Sonic *)sonic actionFired:(SNCHomeTableCellActionType)actionType
{
    sonicToBeViewed = sonic;
    [self performSegueWithIdentifier:ViewSonicSegue sender:self];
    
}

- (void) refresh
{
//    [self.tableView beginUpdates];
    self.sonics = [Sonic getFrom:10 to:20];
    [self.tableView reloadData];
//    [self.tableView endUpdates];
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
//    CGFloat x = self.tableView.contentOffset.x;
//    CGFloat y = self.tableView.contentOffset.y + self.tableView.frame.size.height * 0.5;
//    CGFloat width = self.tableView.frame.size.width;
//    CGFloat height = HeightForHomeCell * 0.4;
//    y -= height * 0.5;
//    CGRect rect = CGRectMake(x, y, width, height);
//    
//    NSArray* indexPaths = [self.tableView indexPathsForRowsInRect:rect];
//    if([indexPaths count] == 1){
//        cellWiningTheCenter = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:0]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cellWiningTheCenter cellWonCenterOfTableView];
//        });
//
//    }
//    else {
//        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL *stop) {
//            SNCHomeTableCell* cell = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [cell cellLostCenterOfTableView];
//            });
//        }];
//    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [cellWiningTheCenter cellLostCenterOfTableView];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:ViewSonicSegue]){
        SNCSonicViewController* sonicViewController =  segue.destinationViewController;
        [sonicViewController setSonic:sonicToBeViewed];
        [sonicViewController initiateFor:SonicViewControllerInitiationTypeCommentWrite];
    }
}

@end
