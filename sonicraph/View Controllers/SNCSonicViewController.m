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
#import "TypeDefs.h"
#import "SonicComment.h"
#import "Configurations.h"
#import "UIButton+StateProperties.h"
#import "SonicCommentCell.h"
#import "SNCPersonTableCell.h"
#import "NSDate+NVTimeAgo.h"
#import "AuthenticationManager.h"

#define AlertViewConfirmResonic 330
#define AlertViewConfirmDeleteResonic 339

#define CellIdentifierSonicComment @"CellIdentifierSonicComment"

typedef void (^AnimationFrame)(CGFloat ratio);
void animateWithFrameRecursive(NSDate* startTime, CGFloat duration, AnimationFrame frame){
    NSDate* currentTime = [NSDate date];
    CGFloat ratio = 0.0;
    CGFloat interval = [currentTime timeIntervalSinceDate:startTime];
    if( duration > interval ){
        ratio = interval / duration;
    } else if (duration <= interval){
        ratio = 1.0;
    }
    frame(ratio);
    if (ratio <= 1.0){
        dispatch_async(dispatch_get_main_queue(), ^{
            animateWithFrameRecursive(startTime, duration, frame);
        });
    }
}
void animateWithFrame(CGFloat duration,AnimationFrame frame){
    NSDate* startTime = [NSDate date];
    animateWithFrameRecursive(startTime, duration, frame);
}


@implementation SNCSonicViewController
{
    ContentType currentContentType;
    BOOL keyboardIsShown;
    User* selectedUser;
}



- (CGRect) tabbarMaxFrame
{
    return CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height, 320.0, self.tabBarController.tabBar.frame.size.height);
}

- (CGRect) tabbarMinFrame
{
    return CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height + self.tabBarController.tabBar.frame.size.height, 320.0, self.tabBarController.tabBar.frame.size.height);
}
- (CGRect) keyBoardCloserFrame
{
    return CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}
- (CGRect) tableHeaderViewFrame
{
    return CGRectMake(0.0, 0.0, 320.0, HeaderViewMaxHeight);
}
- (CGRect) headerViewFrame
{
    return CGRectMake(0.0,0.0, 320.0, HeaderViewMaxHeight);
}
- (CGRect) tabActionBarContentFrame
{
    return CGRectMake(0.0, 0.0, 320.0, self.tabBarController.tabBar.frame.size.height);
}

- (CGRect) tabActionBarViewMaxFrame
{
    return CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height + 88.0, 320.0, 44.0);
}

- (CGRect) tabActionBarViewMinFrame
{
    return CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height - 44.0, 320.0, 44.0);
}

- (CGRect) commentFieldFrame
{
    return CGRectMake(10.0, 7.0, 300.0, 30.0);
}

- (CGRect) commentSubmitButtonFrame
{
    return CGRectMake(260.0, 0.0, 60.0, 44.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commentsContent = [NSMutableArray new];
    self.likesContent = [NSMutableArray new];
    self.resonicsContent = [NSMutableArray new];
    [self initTableView];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MoreWhite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openActionsMenu)]];
    
    [self initHeaderViews];
    [self initTabsViews];
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl = self.refreshControl;
//    [self.refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:self.view.window];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(commentDeletedNotification:)
     name:NotificationCommentDeleted
     object:nil];
    [self configureViews];

}
- (void) commentDeletedNotification:(NSNotification*)notification
{
    SonicComment* comment = notification.object;
    if([comment isKindOfClass:[SonicComment class]]){
        [self.commentsContent removeObject:comment];
        [self reloadData];
    }
}
- (void) initTableView
{
    CGRect frame = [self frameForScrollContent];
    frame.size.height = self.view.frame.size.height - [self heightOfNavigationBar];
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SonicCommentCell class] forCellReuseIdentifier:CellIdentifierSonicComment];
    [self.tableView registerClass:[SNCPersonTableCell class] forCellReuseIdentifier:SNCPersonTableCellIdentifier];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.tableView setTableFooterView:[UIView new]];
    [self setTableViewContentSize];
    [self.view addSubview:self.tableView];
    
}

- (void) initTabsViews
{
    self.tabActionBarView = [[UIView alloc] initWithFrame:[self tabActionBarViewMaxFrame]];
    [self.tabActionBarView setUserInteractionEnabled:YES];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.tabActionBarView];
    self.tabActionBarView.backgroundColor = rgb(235, 235, 235);
    
    self.writeCommentView = [[UIView alloc] initWithFrame:[self tabActionBarContentFrame]];
    [self.writeCommentView.layer setCornerRadius:5.0];
    [self.writeCommentView setUserInteractionEnabled:YES];
    
    self.commentField = [[UITextField alloc] initWithFrame:[self commentFieldFrame]];
    [self.commentField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)]];
    [self.commentField setLeftViewMode:UITextFieldViewModeAlways];
    [self.commentField setPlaceholder:@"Say something nice.."];
    [self.commentField setFont:[self.commentField.font fontWithSize:14.0]];
    [self.commentField setBackgroundColor:[UIColor whiteColor]];
    [self.commentField setUserInteractionEnabled:YES];
    [self.commentField.layer setCornerRadius:5.0];
    [self.commentField.layer setBorderWidth:1.0];
    [self.commentField.layer setBorderColor:self.tabActionBarView.backgroundColor.CGColor];
    [self.writeCommentView addSubview:self.commentField];
    
    self.commentSubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.commentSubmitButton setFrame:[self commentSubmitButtonFrame]];
    [self.commentSubmitButton addTarget:self action:@selector(writeComment) forControlEvents:UIControlEventTouchUpInside];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
    [self.writeCommentView addSubview:self.commentSubmitButton];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    
    self.resonicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resonicButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];

    [@[self.likeButton, self.resonicButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setFrame:[self tabActionBarContentFrame]];
        [button setBackgroundImageWithColor:self.tabActionBarView.backgroundColor forState:UIControlStateNormal];
    }];

}

- (void) initHeaderViews
{
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:[self tableHeaderViewFrame]]];
    //    [self.tableView.tableHeaderView setClipsToBounds:YES];
    [self.tableView.tableHeaderView setUserInteractionEnabled:YES];
    
    self.headerView = [[SonicViewControllerHeaderView alloc] init];
    [self.headerView setFrame:[self headerViewFrame]];
    [self.tableView.tableHeaderView addSubview:self.headerView];
    
//    self.headerView.segmentedBar.delegate = self;
    [self.headerView.segmentedBar addTarget:self action:@selector(segmentedBarChanged) forControlEvents:UIControlEventValueChanged];
    [self.headerView addTargetForTapToTop:self action:@selector(scrollToTop)];

    UITapGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.headerView.profileImageView addGestureRecognizer:tapGesture];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.headerView.usernameLabel addGestureRecognizer:tapGesture];
    [self.headerView.profileImageView setUserInteractionEnabled:YES];
    [self.headerView.usernameLabel setUserInteractionEnabled:YES];
}

- (void) tapGesture
{
    [self openProfileForUser:self.sonic.owner];
}

- (void) openActionsMenu
{
    
}

- (void) scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}
- (void) scrollToContentTop
{
    [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight) animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self.tabBarController.tabBar setFrame:[self tabbarMaxFrame]];
    }];
    [self closeKeyboard];
    [self.tabActionBarView removeFromSuperview];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.tabActionBarView];
    [self setTableViewContentSize];
    if(self.initiationType == SonicViewControllerInitiationTypeCommentWrite){
        [self.commentField becomeFirstResponder];
        self.initiationType = SonicViewControllerInitiationTypeNone;
    }
}
- (void) initiateFor:(SonicViewControllerInitiationType)initiationType
{
    self.initiationType = initiationType;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat navigationHeight = -1.0;
    if(navigationHeight == -1.0){
        navigationHeight =  [self heightOfNavigationBar];
    }
    CGFloat height;
    CGFloat ratio = [self extractRatioFromTopOffset:scrollView.contentOffset.y  andHeight:&height];
    ratio = ratio > 0.0 ? ratio : 0.0;
    [self.headerView reorganizeForRatio:ratio];
    if (ratio <= 0){
        if (self.headerView.superview != self.view){
            [self.view addSubview:self.headerView];
        }
        CGRect frame = [self headerViewFrame];
        frame.origin.y = HeaderViewMinHeight - HeaderViewMaxHeight;
        [self.headerView setFrame:frame];
    } else {
        if(self.headerView.superview != self.tableView.tableHeaderView){
            [self.tableView.tableHeaderView addSubview:self.headerView];
        }
        [self.headerView setFrame:[self headerViewFrame]];
    }
    if (ratio < 0.3){
        [self.headerView setBackgroundColor:[rgb(245, 245, 245) colorWithAlphaComponent:1.0 - (ratio/0.3)*1.0]];
    } else {
        [self.headerView setBackgroundColor:[rgb(245, 245, 245) colorWithAlphaComponent:0.0]];
    }
    
    [self.tabActionBarView setFrame:CGRectByRatio([self tabActionBarViewMaxFrame], [self tabActionBarViewMinFrame], ratio)];

    [self.tabBarController.tabBar setFrame:CGRectByRatio([self tabbarMaxFrame], [self tabbarMinFrame], ratio > 1.0 ? 1.0 : ratio)];

}


- (CGFloat) extractRatioFromTopOffset:(CGFloat)topOffset andHeight:(inout CGFloat*)height
{
    CGFloat tempHeight = HeaderViewMaxHeight - topOffset;
    if(height){
        *height = tempHeight;
    }
    return (tempHeight-HeaderViewMinHeight) / (HeaderViewMaxHeight - HeaderViewMinHeight);
}


- (void) configureViews
{
    if( ! [self isViewLoaded]){
        return;
    }
    else if(self.sonic == nil){
        return;
    }
    if (self.sonic.isLikedByMe){
        [self setLikeButtonSelected];
    } else {
        [self setLikeButtonUnselected];
    }
    if ([self.sonic.owner.userId isEqualToString:[[[AuthenticationManager sharedInstance] authenticatedUser] userId]]){
        [self setResonicButtonUnselected];
        [self.resonicButton setEnabled:NO];
    }
    else if (self.sonic.isResonicedByMe){
        [self setResonicButtonSelected];
    } else {
        [self setResonicButtonUnselected];
    }
    BOOL scrollToContentTop = NO;
    if(self.initiationType == SonicViewControllerInitiationTypeCommentWrite || self.initiationType == SonicViewControllerInitiationTypeCommentRead){
        [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight)];
        [self setCurrentContentType:ContentTypeComments];
        [self.headerView.segmentedBar setSelectedSegmentIndex:1];
        scrollToContentTop = YES;
    } else if(self.initiationType == SonicViewControllerInitiationTypeLikeRead){
        [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight)];
        [self setCurrentContentType:ContentTypeLikes];
        [self.headerView.segmentedBar setSelectedSegmentIndex:0];
        scrollToContentTop = YES;
    } else if(self.initiationType == SonicViewControllerInitiationTypeResonicRead){
        [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight)];
        [self setCurrentContentType:ContentTypeResonics];
        [self.headerView.segmentedBar setSelectedSegmentIndex:2];
        scrollToContentTop = YES;
    }
//    else {
//        [self.tableView setContentOffset:CGPointMake(0.0,0.0)];
//        [self setCurrentContentType:ContentTypeComments];
//        [self.headerView.segmentedBar setSelectedSegmentIndex:1];
//        scrollToContentTop = NO;
//    }
    
    [self refreshContentWithScrollToContentTop:scrollToContentTop];
    
    [self.headerView.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    self.headerView.usernameLabel.text = [@"@" stringByAppendingString:self.sonic.owner.username] ;
    self.headerView.fullnameLabel.text = self.sonic.owner.fullName;
    self.headerView.createdAtLabel.text = [self.sonic.creationDate formattedAsTimeAgo];
    [self.headerView.profileImageView setImage:SonicPlaceholderImage];
    [self.sonic.owner getThumbnailProfileImageWithCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.profileImageView.image = (UIImage*) object;
        });
    }];
    
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

#pragma mark - Content methods

- (NSArray*) currentContent
{
    switch (currentContentType) {
        case ContentTypeLikes:
            return self.likesContent;
        case ContentTypeComments:
            return self.commentsContent;
        case ContentTypeResonics:
            return self.resonicsContent;
        default:
            return nil;
    }
}

- (void) setCurrentContentType:(ContentType)contentType
{
    currentContentType = contentType;
    for (UIView* subview in self.tabActionBarView.subviews) {
        [subview removeFromSuperview];
    }
    switch (currentContentType) {
        case ContentTypeComments:
            [self.tabActionBarView addSubview:self.writeCommentView];
            break;
        case ContentTypeLikes:
            [self.tabActionBarView addSubview:self.likeButton];
            break;
        case ContentTypeResonics:
            [self.tabActionBarView addSubview:self.resonicButton];
            break;
        default:
            [self.navigationItem setTitle:@""];
            break;
    }
    [self refreshNavigationItemText];
    [self reloadData];
}

- (void) refreshNavigationItemText
{
    switch (currentContentType) {
        case ContentTypeComments:
            [self.navigationItem setTitle:[CommentsText stringByAppendingString:[NSString stringWithFormat:@" (%d)",self.sonic.commentCount]]];
            break;
        case ContentTypeLikes:
            [self.navigationItem setTitle:[LikesText stringByAppendingString:[NSString stringWithFormat:@" (%d)",self.sonic.likeCount]]];
            break;
        case ContentTypeResonics:
            [self.navigationItem setTitle:[ResonicsText stringByAppendingString:[NSString stringWithFormat:@" (%d)",self.sonic.resonicCount]]];
            break;
        default:
            [self.navigationItem setTitle:@"Sonic"];
            break;
    }
}
- (void) refreshContentWithScrollToContentTop:(BOOL)scrollToContentTop
{
    [self reloadData];
    if(scrollToContentTop)
    {
        [self scrollToContentTop];
    }
    if(currentContentType == ContentTypeLikes){
        [SNCAPIManager getLikesOfSonic:self.sonic withCompletionBlock:^(NSArray *users) {
            self.likesContent = [users mutableCopy];
            [self reloadData];
            if(scrollToContentTop)
            {
                [self scrollToContentTop];
            }
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
    else if(currentContentType == ContentTypeComments){
        [SNCAPIManager getCommentsOfSonic:self.sonic withCompletionBlock:^(NSArray *comments) {
            self.commentsContent = [comments mutableCopy];
            [self reloadData];
            if(scrollToContentTop)
            {
                [self scrollToContentTop];
            }
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
    else if(currentContentType == ContentTypeResonics){
        [SNCAPIManager getResonicsOfSonic:self.sonic withCompletionBlock:^(NSArray *resonics) {
            self.resonicsContent = [resonics mutableCopy];
            [self reloadData];
            if(scrollToContentTop)
            {
                [self scrollToContentTop];
            }
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
}

- (void)segmentedBarChanged
{
    [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight-HeaderViewMinHeight) animated:YES];
    switch (self.headerView.segmentedBar.selectedSegmentIndex) {
        case 0:
            [self setCurrentContentType:ContentTypeLikes];
            if(self.likesContent == nil|| self.likesContent.count == 0){
                [self refreshContentWithScrollToContentTop:YES];
            }
            break;
        case 1:
            [self setCurrentContentType:ContentTypeComments];
            if(self.commentsContent == nil || self.commentsContent.count == 0){
                [self refreshContentWithScrollToContentTop:YES];
            }
            break;
        case 2:
            [self setCurrentContentType:ContentTypeResonics];
            if(self.resonicsContent == nil || self.resonicsContent.count == 0){
                [self refreshContentWithScrollToContentTop:YES];
            }
            break;
            
        default:
            break;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == AlertViewConfirmResonic){
        if(buttonIndex == 0){
            [self resonicConfirm];
        }
    }
    else if(alertView.tag == AlertViewConfirmDeleteResonic){
        if(buttonIndex == 0){
            [self deleteResonicConfirm];
        }
    }
}

#pragma mark - Action tab bar methods

- (void) setLikeButtonSelected
{
    [self.likeButton setBackgroundImageWithColor:PinkColor forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"LikeWhite.png"] forState:UIControlStateNormal];
    [self.likeButton setTitle:@"You liked this sonic :)" forState:UIControlStateNormal];
    [self.likeButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.likeButton addTarget:self action:@selector(unlikeSonic) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
}

- (void) setLikeButtonUnselected
{
    [self.likeButton setBackgroundImageWithColor:self.tabActionBarView.backgroundColor forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"LikePink.png"] forState:UIControlStateNormal];
    [self.likeButton setTitle:@"" forState:UIControlStateNormal];
    [self.likeButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.likeButton addTarget:self action:@selector(likeSonic) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

- (void) likeSonic
{
    [self setLikeButtonSelected];
    [self.likesContent addObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [self reloadData];
    [SNCAPIManager likeSonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
        [self.sonic updateWithSonic:sonic];
        [self refreshNavigationItemText];
    } andErrorBlock:^(NSError *error) {
        [self setLikeButtonUnselected];
        [self.likesContent removeObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
        [self reloadData];
        [self refreshNavigationItemText];
    }];
}

- (void) unlikeSonic
{
    [self setLikeButtonUnselected];
    [self.likesContent removeObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [self reloadData];
    [SNCAPIManager dislikeSonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
        [self.sonic updateWithSonic:sonic];
        [self refreshNavigationItemText];
    } andErrorBlock:^(NSError *error) {
        [self setLikeButtonSelected];
        [self.likesContent addObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
        [self reloadData];
        [self refreshNavigationItemText];
    }];
}

- (void) setResonicButtonSelected
{
    [self.resonicButton setBackgroundImageWithColor:PinkColor forState:UIControlStateNormal];
    [self.resonicButton setImage:[UIImage imageNamed:@"ResonicWhite.png"] forState:UIControlStateNormal];
    [self.resonicButton setTitle:@"You resoniced this sonic :)" forState:UIControlStateNormal];
    [self.resonicButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.resonicButton addTarget:self action:@selector(deleteResonic) forControlEvents:UIControlEventTouchUpInside];
    [self.resonicButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
}

- (void) setResonicButtonUnselected
{
    [self.resonicButton setBackgroundImageWithColor:self.tabActionBarView.backgroundColor forState:UIControlStateNormal];
    [self.resonicButton setImage:[UIImage imageNamed:@"ResonicPink.png"] forState:UIControlStateNormal];
    [self.resonicButton setTitle:@"" forState:UIControlStateNormal];
    [self.resonicButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.resonicButton addTarget:self action:@selector(resonic) forControlEvents:UIControlEventTouchUpInside];
    [self.resonicButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
}

- (void) resonic
{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"Resonic"
                          message:@"Do you want to resonic?"
                          delegate:self
                          cancelButtonTitle:@"Resonic"
                          otherButtonTitles:@"Cancel", nil];
    alert.tag = AlertViewConfirmResonic;
    [alert show];
}

- (void) deleteResonic
{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"Delete Resonics"
                          message:@"Do you want to delete resonic?"
                          delegate:self
                          cancelButtonTitle:@"Delete"
                          otherButtonTitles:@"Cancel", nil];
    alert.tag = AlertViewConfirmDeleteResonic;
    [alert show];
}

- (void) resonicConfirm
{
    [self setResonicButtonSelected];
    [self.resonicsContent addObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [self reloadData];
    [SNCAPIManager resonicSonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
        [self.sonic updateWithSonic:sonic];
        [self refreshNavigationItemText];
    } andErrorBlock:^(NSError *error) {
        [self setResonicButtonUnselected];
        [self.resonicsContent removeObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
        [self reloadData];
    }];
}

- (void) deleteResonicConfirm
{
    [self setResonicButtonUnselected];
    [self.resonicsContent removeObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
    [self reloadData];
    [SNCAPIManager resonicSonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
        [self.sonic updateWithSonic:sonic];
        [self refreshNavigationItemText];
    } andErrorBlock:^(NSError *error) {
        [self setResonicButtonSelected];
        [self.resonicsContent addObject:[[AuthenticationManager sharedInstance] authenticatedUser]];
        [self reloadData];
    }];
}

#pragma mark - Table view methods
- (void) setTableViewContentSize
{
    
    CGFloat height = HeaderViewMaxHeight + self.tableView.frame.size.height - HeaderViewMinHeight;
    CGFloat insetBottom = height - self.tableView.contentSize.height;
    NSLog(@"insetBottom %f, tabbar: %f", insetBottom, self.tabBarController.tabBar.frame.size.height);
    insetBottom = MAX(insetBottom, self.tabBarController.tabBar.frame.size.height);
//    insetBottom = MAX(insetBottom, self.tabBarController.tabBar.frame.size.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, insetBottom, 0.0);
    
}
- (void) reloadData
{
    CGSize firstSize = self.tableView.contentSize;
    CGPoint scrollPoint = self.tableView.contentOffset;
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, 1.0);
    [self setTableViewContentSize];
    [self.tableView setContentSize:firstSize];
    [self.tableView setContentOffset:scrollPoint];
    [self.tableView reloadData];
    [self setTableViewContentSize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self currentContent]){
        return [[self currentContent] count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentContentType == ContentTypeComments){
        SonicComment* comment = [[self currentContent] objectAtIndex:indexPath.row];
        return [SonicCommentCell cellHeightForText:comment.text];
    } else {
        return PersonTableCellHeight;
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self setTableViewContentSize];
    }
}



- (void) writeComment
{
    [self.commentField setEnabled:NO];
    [self closeKeyboard];
    [SNCAPIManager writeCommentToSonic:self.sonic withText:self.commentField.text withCompletionBlock:^(id object) {
        [self.commentsContent addObject:object];
        [self reloadData];
        [self.commentField setText:@""];
        [self.commentField setEnabled:YES];
        //        [self refreshContent];
    } andErrorBlock:^(NSError *error) {
        [self.commentField setEnabled:YES];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(currentContentType == ContentTypeComments){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSonicComment forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:SNCPersonTableCellIdentifier forIndexPath:indexPath];
    }
    id currentObject = [[self currentContent] objectAtIndex:indexPath.row];
    if(currentContentType == ContentTypeLikes){
        [(SNCPersonTableCell*)cell setUser:currentObject];
        [(SNCPersonTableCell*)cell setDelegate:self];
    } else if (currentContentType == ContentTypeComments){
        [(SonicCommentCell*)cell setSonicComment:currentObject];
        [(SonicCommentCell*)cell setDelegate:self];
    } else if (currentContentType == ContentTypeResonics){
        [(SNCPersonTableCell*)cell setUser:currentObject];
        [(SNCPersonTableCell*)cell setDelegate:self];
    }
    return cell;
}


- (void) closeKeyboard
{
    [self.commentField resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    //    [self.tags setFrame:[self tagsFrame]];
    [self.tabActionBarView setFrame:[self tabActionBarViewMinFrame]];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }
    
    [self.view addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)]];
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    CGRect frame = [self tabActionBarViewMinFrame];
    frame.origin.y = frame.origin.y - keyboardSize.height;
    [self.tabActionBarView setFrame:frame];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void) openProfileForUser:(User *)user
{
    selectedUser = user;
    [self performSegueWithIdentifier:SonicToProfileSegue sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SonicToProfileSegue]) {
        SNCProfileViewController* profile = segue.destinationViewController;
        [profile setUser:selectedUser];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:nil
     object:nil];
}

@end
