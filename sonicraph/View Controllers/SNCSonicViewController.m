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

#define CellIdentifierSonicComment @"CellIdentifierSonicComment"

@implementation SNCSonicViewController
{
    ContentType currentContentType;
    BOOL keyboardIsShown;
}

- (CGRect) tabbarMaxFrame
{
    return CGRectMake(0.0, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height, 320.0, self.tabBarController.tabBar.frame.size.height);
}

- (CGRect) tabbarMinFrame
{
    return CGRectMake(0.0, self.view.frame.size.height + self.tabBarController.tabBar.frame.size.height, 320.0, self.tabBarController.tabBar.frame.size.height);
}
- (CGRect) keyBoardCloserFrame
{
    return CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}
- (CGRect) tableHeaderViewFrame
{
    return CGRectMake(0.0, 0.0, 320.0, HeaderViewMaxHeight + self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
}
- (CGRect) headerViewFrame
{
    return CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, 320.0, HeaderViewMaxHeight);
}
- (CGRect) tabActionBarContentFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

- (CGRect) tabActionBarViewMaxFrame
{
    return CGRectMake(0.0, self.view.frame.size.height + 88.0, 320.0, 44.0);
}

- (CGRect) tabActionBarViewMinFrame
{
    return CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0);
}

- (CGRect) commentFieldFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

- (CGRect) commentSubmitButtonFrame
{
    return CGRectMake(260.0, 0.0, 60.0, 44.0);
}

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
            [self.navigationItem setTitle:@"Comments"];
            [self.tabActionBarView addSubview:self.writeCommentView];
            break;
        case ContentTypeLikes:
            [self.navigationItem setTitle:@"Likes"];
            [self.tabActionBarView addSubview:self.likeButton];
            break;
        case ContentTypeResonics:
            [self.navigationItem setTitle:@"Resonics"];
            [self.tabActionBarView addSubview:self.resonicButton];
            break;
        default:
            [self.navigationItem setTitle:@""];
            break;
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commentsContent = @[];
    self.likesContent = @[];
    self.resonicsContent = @[];
    [self initTableView];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MoreWhite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openActionsMenu)]];
    
    [self initHeaderViews];
    [self initTabsViews];
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl = self.refreshControl;
//    [self.refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [self configureViews];
    

}
- (void) initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SonicCommentCell class] forCellReuseIdentifier:CellIdentifierSonicComment];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, HeaderViewMaxHeight * 2.0, 0.0)];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.0, 64.0, 0.0, 0.0)];
    [self.tableView setTableFooterView:[UIView new]];
    
    //    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    
}

- (void) initTabsViews
{
    self.tabActionBarView = [[UIView alloc] initWithFrame:[self tabActionBarViewMaxFrame]];
    [self.view addSubview:self.tabActionBarView];
    
    self.writeCommentView = [[UIView alloc] initWithFrame:[self tabActionBarContentFrame]];
    [self.writeCommentView setBackgroundColor:[UIColor whiteColor]];
    
    self.commentField = [[UITextField alloc] initWithFrame:[self commentFieldFrame]];
    [self.commentField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 44.0)]];
    [self.commentField setPlaceholder:@"Write comment"];
    [self.writeCommentView addSubview:self.commentField];
    
    self.commentSubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.commentSubmitButton setFrame:[self commentSubmitButtonFrame]];
    [self.commentSubmitButton addTarget:self action:@selector(writeComment) forControlEvents:UIControlEventTouchUpInside];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
    [self.writeCommentView addSubview:self.commentSubmitButton];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"HeartPink.png"] forState:UIControlStateNormal];
    
    self.resonicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resonicButton setTitle:@"Resonic" forState:UIControlStateNormal];
    [self.resonicButton setImage:[UIImage imageNamed:@"ReSonicPink.png"] forState:UIControlStateNormal];
    [@[self.likeButton, self.resonicButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setFrame:[self tabActionBarContentFrame]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 40.0)];
        button.titleLabel.font = [button.titleLabel.font fontWithSize:18.0];
        [button setBackgroundImageWithColor:NavigationBarBlueColor forState:UIControlStateNormal];
    }];
    
    [@[self.commentField,self.likeButton,self.resonicButton] enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        [view.layer setBorderColor:NavigationBarBlueColor.CGColor];
        [view.layer setBorderWidth:1.0];
        [view.layer setCornerRadius:5.0];
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
    
    self.headerViewShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Shadow.png"]];
    [self.headerViewShadow setFrame:CGRectMake(0.0, [self headerViewFrame].size.height, self.view.frame.size.width, self.headerViewShadow.image.size.height)];
    self.headerView.segmentedBar.delegate = self;
    [self.headerView addTargetForTapToTop:self action:@selector(scrollToTop)];
    [self.headerView addSubview:self.headerViewShadow];

}

- (void) openActionsMenu
{
    
}

- (void) scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self.tabBarController.tabBar setFrame:[self tabbarMaxFrame]];
    }];
}

- (void) initiateFor:(SonicViewControllerInitiationType)initiationType
{
    self.initiationType = initiationType;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat navigationHeight = -1.0;
    if(navigationHeight == -1.0){
        navigationHeight =  self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    CGFloat height;
    CGFloat ratio = [self extractRatioFromTopOffset:scrollView.contentOffset.y  andHeight:&height];
    ratio = ratio > 0.0 ? ratio : 0.0;
    [self.headerView reorganizeForRatio:ratio];
    if(height <= HeaderViewMinHeight){
        if (self.headerView.superview != self.view){
            [self.view addSubview:self.headerView];
        }
        CGRect frame = [self headerViewFrame];
        frame.origin.y = navigationHeight + HeaderViewMinHeight - HeaderViewMaxHeight;
        [self.headerView setFrame:frame];
    } else {
        if(self.headerView.superview != self.tableView.tableHeaderView){
            [self.tableView.tableHeaderView addSubview:self.headerView];
        }
        [self.headerView setFrame:[self headerViewFrame]];
    }
    [self.headerViewShadow setAlpha:0.0];
    if (ratio < 0.3){
//        self.headerViewShadow.alpha = 1.0 - (ratio/0.05)*1.0;
        [self.headerView setBackgroundColor:[rgb(245, 245, 245) colorWithAlphaComponent:1.0 - (ratio/0.3)*1.0]];
    } else {
//        self.headerViewShadow.alpha = 0.0;
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

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self calculateAndAnimateToContentOffset];
}

- (void) calculateAndAnimateToContentOffset
{
    CGFloat height;
    CGFloat ratio = [self extractRatioFromTopOffset:self.tableView.contentOffset.y andHeight:&height];
    if(ratio > 0.0 && ratio < 1.0){
        CGFloat velocityY = [self.tableView.panGestureRecognizer velocityInView:self.tableView].y;
        if(velocityY > 0.0){
            [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight) animated:YES];
        }
    }
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y != 0.0){
        return;
    }
    [self calculateAndAnimateToContentOffset];

}


- (void) configureViews
{
    if( ! [self isViewLoaded]){
        return;
    }
    else if(self.sonic == nil){
        return;
    }
    
    if(self.initiationType == SonicViewControllerInitiationTypeCommentWrite){
        [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight)];
        [self setCurrentContentType:ContentTypeComments];
        [self.headerView.segmentedBar setSelectedIndex:1];
    }
    
    [self refreshContent];
    [self.headerView.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    [self.headerView.profileImageView setImage:[UIImage imageNamed:@"2013-11-07 09.52.53.jpg"]];
    [self.headerView.usernameLabel setText:@"yeguzel"];
    
    /*TEST*/
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


- (void) refreshContent
{
    if(currentContentType == ContentTypeLikes){
//        [SNCAPIManager getLikesOfSonic:self.sonic withCompletionBlock:^(NSArray *users) {
//            self.likesContent = users;
//            [self.tableView reloadData];
//            
//        } andErrorBlock:^(NSError *error) {
//            
//        }];
    }
    else if(currentContentType == ContentTypeComments){
        [SNCAPIManager getCommentsOfSonic:self.sonic withCompletionBlock:^(NSArray *comments) {
            self.commentsContent = comments;
            [self.tableView reloadData];
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
    else if(currentContentType == ContentTypeResonics){
        
    }
    [self.tableView reloadData];
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
    if([self currentContent]){
        return [[self currentContent] count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (void) writeComment
{

    [self.commentField setEnabled:NO];
    [self closeKeyboard];
    [SNCAPIManager writeCommentToSonic:self.sonic withText:self.commentField.text withCompletionBlock:^(id object) {
        self.commentsContent = [self.commentsContent arrayByAddingObject:object];
        [self.tableView reloadData];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    id currentObject = [[self currentContent] objectAtIndex:indexPath.row];
    if(currentContentType == ContentTypeLikes){
        [cell.textLabel setText:((User*)currentObject).username];
    } else if (currentContentType == ContentTypeComments){
        [(SonicCommentCell*)cell setSonicComment:currentObject];
    }
    return cell;
}


- (void)segmentedBar:(SegmentedBar *)segmentedBar selectedItemAtIndex:(NSInteger)index
{
    [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight-HeaderViewMinHeight) animated:YES];
    switch (index) {
        case 0:
            [self setCurrentContentType:ContentTypeLikes];
            break;
        case 1:
            [self setCurrentContentType:ContentTypeComments];
            break;
        case 2:
            [self setCurrentContentType:ContentTypeResonics];
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload {
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)dealloc {
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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
    
    self.keyboardCloser = [[UIView alloc] initWithFrame:[self keyBoardCloserFrame]];
    //    [self.keyboardCloser setAlpha:0.0];
    [self.keyboardCloser setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.keyboardCloser addGestureRecognizer:tapGesture];
    [self.view insertSubview:self.keyboardCloser belowSubview:self.tabActionBarView];
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    CGRect frame = [self tabActionBarViewMinFrame];
    frame.origin.y = self.view.frame.size.height - keyboardSize.height - frame.size.height;
    [self.tabActionBarView setFrame:frame];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void) closeKeyboard
{
    [self.keyboardCloser removeFromSuperview];
    [self.commentField resignFirstResponder];
}

@end
