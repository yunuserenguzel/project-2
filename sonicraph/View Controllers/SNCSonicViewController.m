//
//  SNCSonicViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/22/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSonicViewController.h"
#import "SonicPlayerView.h"
#import "SNCAPIManager.h"
#import <QuartzCore/QuartzCore.h>

#define LikesTabButtonTag 5111
#define CommentsTabButtonTag 5112
#define ResonicsTabButtonTag 5113
@interface SNCSonicViewController ()

@property SonicPlayerView* sonicPlayerView;
@property UILabel* usernameLabel;
@property UIImageView* profileImageView;
@property UIView* tabsView;
@property UIButton* likesTabButton;
@property UIButton* commentsTabButton;
@property UIButton* resonicsTabButton;

@property NSArray* likesContent;
@property NSArray* commentsContent;
@property NSArray* resonicsContent;

@end

@implementation SNCSonicViewController
{
    UIButton* selectedTabButton;
    NSArray* currentContent;
}

- (CGRect) tableHeaderViewFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 440.0);
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
}

- (CGRect) profileImageFrame
{
    return CGRectMake(10.0, 11.0, 44.0, 44.0);
}

-(CGRect) usernameLabelFrame
{
    return CGRectMake(64.0, 11.0, 244.0, 44.0);
}

- (CGRect) tabsViewFrame
{
    return CGRectMake(0.0, 396.0, 320.0, 44.0);
}

- (CGRect) likesButtonFrame
{
    return CGRectMake(0.0, 0.0, 320.0 / 3.0, 44.0);
}
- (CGRect) commentsButtonFrame
{
    return CGRectMake(320.0*1.0/3.0, 0.0, 320.0 / 3.0, 44.0);
}
- (CGRect) resonicsButtonFrame
{
    return CGRectMake(320.0*2.0/3.0, 0.0, 320.0 / 3.0, 44.0);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:[self tableHeaderViewFrame]]];

//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl = self.refreshControl;
//    [self.refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    
    [self inititalizeTab];
    [self initSonicPlayerView];
    [self initUserViews];
    selectedTabButton = self.likesTabButton;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self configureViews];
}

- (void) initSonicPlayerView
{
    self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self sonicPlayerViewFrame]];
    [self.tableView.tableHeaderView addSubview:self.sonicPlayerView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat navigationHeight = -1.0;
    if(navigationHeight == -1.0){
        navigationHeight =  self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    CGFloat topOffset = scrollView.contentOffset.y + navigationHeight;
//    CGFloat topOffset = scrollView.contentOffset.y;
//    CGFloat difference = topOffset - frame.origin.y;
//    NSLog(@"topOffset: %f difference: %f",topOffset,difference);
    
    if(topOffset <= 0){
        topOffset = 0.0;
        [self.sonicPlayerView setUserInteractionEnabled:YES];
    }
    
    if(topOffset >= 0.0 && topOffset < 321.0){
        [self.sonicPlayerView setUserInteractionEnabled:NO];
        CGRect sonicPlayerViewframe = [self sonicPlayerViewFrame];
        sonicPlayerViewframe.origin.y += topOffset - (topOffset / 320.0)*66.0;
        CGFloat change = topOffset - (topOffset / 320.0)*66.0;
        sonicPlayerViewframe.origin.x = change;
        sonicPlayerViewframe.size.height -= change;
        sonicPlayerViewframe.size.width -= change;
        [self.sonicPlayerView setFrame:sonicPlayerViewframe];
        CGFloat alpha = fabs(160 - topOffset) / 160;
        alpha = alpha / 2.0 + 0.5;
        alpha = alpha > 0.95 ? 1.0 : 0.8;
        [self.sonicPlayerView setAlpha:alpha];
        
        CGRect profileImageView = [self profileImageFrame];
        profileImageView.origin.y += topOffset;
        [self.profileImageView setFrame:profileImageView];
        
        CGRect usernameLabelFrame = [self usernameLabelFrame];
        usernameLabelFrame.origin.y += topOffset;
        [self.usernameLabel setFrame:usernameLabelFrame];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.decelerationRate);
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y != 0.0){
        return;
    }
    NSLog(@"velocity: %f, %f",velocity.x,velocity.y);
    static CGFloat navigationHeight = -1.0;
    if(navigationHeight == -1.0){
        navigationHeight =  self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    CGFloat topOffset = scrollView.contentOffset.y + navigationHeight;
    if(topOffset > 0.0 && topOffset <= [self tableHeaderViewFrame].size.height * 0.5){
        *targetContentOffset = CGPointMake(0.0, -navigationHeight);
    } else if(topOffset >= [self tableHeaderViewFrame].size.height * 0.5 && topOffset < 321.0){
        *targetContentOffset = CGPointMake(0.0, 254.0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        return;
    }
    
}

- (void) initUserViews
{
    self.profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageFrame]];
    [self.profileImageView.layer setCornerRadius:22.0];
    [self.profileImageView.layer setRasterizationScale:2.0];
    [self.profileImageView.layer setShouldRasterize:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self.tableView.tableHeaderView addSubview:self.profileImageView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.tableView.tableHeaderView addSubview:self.usernameLabel];
}

- (void) configureViews
{
    if( ! [self isViewLoaded]){
        return;
    }
    else if(self.sonic == nil){
        return;
    }
    
    [self refreshContent];
    [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    [self.profileImageView setImage:[UIImage imageNamed:@"dummy_profile_image.jpg"]];
    [self.usernameLabel setText:@"yeguzel"];
}

- (void)setSonic:(Sonic *)sonic
{
    _sonic = sonic;
    [self configureViews];
}

- (void) inititalizeTab
{
    self.tabsView = [[UIView alloc] initWithFrame:[self tabsViewFrame]];
    [self.tabsView setUserInteractionEnabled:YES];
    [self.tableView.tableHeaderView addSubview:self.tabsView];
    
    self.likesTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.likesTabButton.frame = [self likesButtonFrame];
    [self.likesTabButton setTitle:@"Likes" forState:UIControlStateNormal];
    self.likesTabButton.tag = LikesTabButtonTag;
    
    self.commentsTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.commentsTabButton.frame = [self commentsButtonFrame];
    [self.commentsTabButton setTitle:@"Comments" forState:UIControlStateNormal];
    self.commentsTabButton.tag = CommentsTabButtonTag;

    self.resonicsTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.resonicsTabButton.frame = [self resonicsButtonFrame];
    [self.resonicsTabButton setTitle:@"Resonics" forState:UIControlStateNormal];
    self.resonicsTabButton.tag = ResonicsTabButtonTag;
    
    [@[self.likesTabButton,self.commentsTabButton,self.resonicsTabButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [self.tabsView addSubview:button];
        [button addTarget:self action:@selector(changeTabForButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) changeTabForButton:(UIButton*)button
{
    if(button.tag == LikesTabButtonTag){
        if(self.likesContent == nil){
            
        }
    }
    else if(button.tag == CommentsTabButtonTag){
        
    }
    else if(button.tag == ResonicsTabButtonTag){
        
    }
    selectedTabButton = button;
    [self.tableView reloadData];
}

- (void) refreshContent
{
    if(selectedTabButton.tag == LikesTabButtonTag){
        [SNCAPIManager getLikesOfSonic:self.sonic withCompletionBlock:^(NSArray *users) {
            self.likesContent = users;
            [self.tableView reloadData];
            
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
    else if(selectedTabButton.tag == CommentsTabButtonTag){
        
    }
    else if(selectedTabButton.tag == ResonicsTabButtonTag){
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 100;
    if(currentContent){
        return [currentContent count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    id currentObject = [currentContent objectAtIndex:indexPath.row];
//    if(selectedTabButton.tag == LikesTabButtonTag){
//        User* user = currentObject;
//        [cell.textLabel setText:user.username];
//    }
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
