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
#import "TypeDefs.h"

#define LikesTabButtonTag 5111
#define CommentsTabButtonTag 5112
#define ResonicsTabButtonTag 5113

#define HeaderViewMaxHeight 440.0
#define HeaderViewMinHeight 88.0

@interface SonicViewControllerHeaderView : UIView

@property SonicPlayerView* sonicPlayerView;
@property UILabel* usernameLabel;
@property UIImageView* profileImageView;

@property UIView* tabsView;
@property UIButton* likesTabButton;
@property UIButton* commentsTabButton;
@property UIButton* resonicsTabButton;

@property Sonic* sonic;

@end

@implementation SonicViewControllerHeaderView
{
    BOOL isInitCalled;
}
- (CGRect) sonicPlayerViewMaxFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
}
-(CGRect) sonicPlayerViewMinFrame
{
    return CGRectMake(320 - 55.0, 0.0, 55.0, 55.0);
}

- (CGRect) profileImageMaxFrame
{
    return CGRectMake(10.0, 11.0, 44.0, 44.0);
}
- (CGRect) profileImageMinFrame
{
    return CGRectMake(10.0, 2.0, 44.0, 44.0);
}

-(CGRect) usernameLabelMaxFrame
{
    return CGRectMake(64.0, 11.0, 244.0, 44.0);
}

-(CGRect) usernameLabelMinFrame
{
    return CGRectMake(64.0, 2.0, 244.0, 44.0);
}

- (CGRect) tabsViewMaxFrame
{
    return CGRectMake(0.0, 396.0, 320.0, 44.0);
}
- (CGRect) tabsViewMinFrame
{
    return CGRectMake(0.0, 44.0, 320.0, 44.0);
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

- (id)init
{
    if(self = [super init]){
        [self initViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    if(isInitCalled){
        return;
    } else {
        isInitCalled = YES;
    }
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setUserInteractionEnabled:YES];
    [self inititalizeTab];
    [self initSonicPlayerView];
    [self initUserViews];
}
- (void) initSonicPlayerView
{
    self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self sonicPlayerViewMaxFrame]];
    [self addSubview:self.sonicPlayerView];
}

- (void) initUserViews
{
    self.profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageMaxFrame]];
    [self.profileImageView.layer setCornerRadius:22.0];
    [self.profileImageView.layer setRasterizationScale:2.0];
    [self.profileImageView.layer setShouldRasterize:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self addSubview:self.profileImageView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelMaxFrame]];
    [self addSubview:self.usernameLabel];
}
- (void) inititalizeTab
{
    self.tabsView = [[UIView alloc] initWithFrame:[self tabsViewMaxFrame]];
    [self.tabsView setUserInteractionEnabled:YES];
    [self addSubview:self.tabsView];
    
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
    }];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat height = frame.size.height;
    CGFloat ratio = (height-HeaderViewMinHeight) / (HeaderViewMaxHeight - HeaderViewMinHeight);
//    ratio = ratio < 0 ? 0 : (ratio > 1 ? 1 : ratio);
    
    [self.sonicPlayerView setFrame:CGRectByRatio([self sonicPlayerViewMaxFrame], [self sonicPlayerViewMinFrame], ratio)];
    [self.profileImageView setFrame:CGRectByRatio([self profileImageMaxFrame], [self profileImageMinFrame], ratio)];
    [self.usernameLabel setFrame:CGRectByRatio([self usernameLabelMaxFrame], [self usernameLabelMinFrame], ratio)];
    [self.tabsView setFrame:CGRectByRatio([self tabsViewMaxFrame], [self tabsViewMinFrame], ratio)];
    
}


- (void) eventListener:(id)listener selector:(SEL) selector
{
    [@[self.likesTabButton,self.commentsTabButton,self.resonicsTabButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button addTarget:listener action:selector forControlEvents:UIControlEventTouchUpInside];
    }];
}
@end

@interface SNCSonicViewController ()

@property SonicViewControllerHeaderView* headerView;

@property NSArray* likesContent;
@property NSArray* commentsContent;
@property NSArray* resonicsContent;

@property UITextField* commentField;
@property UIButton* commentSubmitButton;
@property UIView* writeCommentView;
@property UITableView* tableView;


@end


@implementation SNCSonicViewController
{
    UIButton* selectedTabButton;
    NSArray* currentContent;
}

- (CGRect) tableHeaderViewFrame
{
    return CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, 320.0, HeaderViewMaxHeight);
}
- (CGRect) writeCommentViewFrame
{
    return CGRectMake(0.0, self.view.frame.size.height - 88.0, 320.0, 44.0);
}
- (CGRect) commentFieldFrame
{
    return CGRectMake(0.0, 0.0, 260.0, 44.0);
}

- (CGRect) commentSubmitButtonFrame
{
    return CGRectMake(260.0, 0.0, 60.0, 44.0);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.view.frame));
    NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.tableView.frame));
    
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:[self tableHeaderViewFrame]]];
    [self.tableView.tableHeaderView setUserInteractionEnabled:YES];
    self.headerView = [[SonicViewControllerHeaderView alloc] init];
    
    [self.headerView setFrame:[self tableHeaderViewFrame]];
    [self.tableView.tableHeaderView addSubview:self.headerView];
    
    self.writeCommentView = [[UIView alloc] initWithFrame:[self writeCommentViewFrame]];
    [self.writeCommentView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    [self.view addSubview:self.writeCommentView];
    
    self.commentField = [[UITextField alloc] initWithFrame:[self commentFieldFrame]];
    [self.commentField.layer setBorderColor:[UIColor redColor].CGColor];
    [self.commentField.layer setBorderWidth:1.0];
    [self.commentField.layer setCornerRadius:5.0];
    [self.writeCommentView addSubview:self.commentField];
    
    self.commentSubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.commentSubmitButton setFrame:[self commentSubmitButtonFrame]];
    [self.writeCommentView addSubview:self.commentSubmitButton];
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl = self.refreshControl;
//    [self.refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    
//    selectedTabButton = self.likesTabButton;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItrem = self.editButtonItem;
    [self configureViews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat navigationHeight = -1.0;
    if(navigationHeight == -1.0){
        navigationHeight =  self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    CGFloat topOffset = scrollView.contentOffset.y ;
    NSLog(@"topoffset: %f",topOffset);
    CGFloat height = HeaderViewMaxHeight - topOffset;
    height = height < HeaderViewMinHeight ? HeaderViewMinHeight : height;
    if (height == HeaderViewMinHeight){
        topOffset = 0.0;
    }
        
    [self.headerView setFrame:CGRectMake(0.0, [self tableHeaderViewFrame].origin.y + topOffset , 320.0, height)];


//    if(topOffset <= 0){
//        topOffset = 0.0;
//        [self.sonicPlayerView setUserInteractionEnabled:YES];
//    }
//    if(topOffset >= 0.0 && topOffset < 321.0){
//        
//        
//    } else if ( topOffset >= 321.0){
//        CGRect sonicPlayerViewFrame = [self sonicPlayerViewFrame];
//        CGFloat change = 320.0 - (320.0 / 320.0)*66.0;
//        sonicPlayerViewFrame.origin.y += change + topOffset - 321.0;
//        sonicPlayerViewFrame.origin.x = change;
//        sonicPlayerViewFrame.size.height -= change;
//        sonicPlayerViewFrame.size.width -= change;
//        [self.sonicPlayerView setFrame:sonicPlayerViewFrame];
//    }
//    if (topOffset >= 0){
//        CGRect profileImageView = [self profileImageFrame];
//        profileImageView.origin.y += topOffset;
//        [self.profileImageView setFrame:profileImageView];
//        
//        CGRect usernameLabelFrame = [self usernameLabelFrame];
//        usernameLabelFrame.origin.y += topOffset;
//        [self.usernameLabel setFrame:usernameLabelFrame];
//
//    }
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

- (void) configureViews
{
    if( ! [self isViewLoaded]){
        return;
    }
    else if(self.sonic == nil){
        return;
    }
    
    [self refreshContent];
    [self.headerView.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    [self.headerView.profileImageView setImage:[UIImage imageNamed:@"dummy_profile_image.jpg"]];
    [self.headerView.usernameLabel setText:@"yeguzel"];
}

- (void)setSonic:(Sonic *)sonic
{
    _sonic = sonic;
    [self configureViews];
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
