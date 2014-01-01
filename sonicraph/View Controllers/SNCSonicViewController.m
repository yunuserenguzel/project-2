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
#import "SonicViewControllerHeaderView.h"
#import "SonicComment.h"
#import "Configurations.h"


typedef enum ContentType {
    ContentTypeNone,
    ContentTypeComments,
    ContentTypeLikes,
    ContentTypeResonics
} ContentType;

@interface SNCSonicViewController ()

@property SonicViewControllerHeaderView* headerView;

@property NSArray* likesContent;
@property NSArray* commentsContent;
@property NSArray* resonicsContent;

@property UIView* tabActionBarView;

@property UITextField* commentField;
@property UIButton* commentSubmitButton;
@property UIView* writeCommentView;
@property UITableView* tableView;

@property UIView* keyboardCloser;

@property SonicViewControllerInitiationType initiationType;


@end


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
    return CGRectMake(0.0, self.view.frame.size.height, 320.0, self.tabBarController.tabBar.frame.size.height);
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
- (CGRect) writeCommentViewFrame
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
    switch (currentContentType) {
        case ContentTypeComments:
            [self.navigationItem setTitle:@"Comments"];
            break;
        case ContentTypeLikes:
            [self.navigationItem setTitle:@"Likes"];
            break;
        case ContentTypeResonics:
            [self.navigationItem setTitle:@"Resonics"];
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
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, HeaderViewMaxHeight * 2.0, 0.0)];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
//    NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.view.frame));
//    NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.tableView.frame));

    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:[self tableHeaderViewFrame]]];
//    [self.tableView.tableHeaderView setClipsToBounds:YES];
    [self.tableView.tableHeaderView setUserInteractionEnabled:YES];
    
    self.headerView = [[SonicViewControllerHeaderView alloc] init];
    [self.headerView setFrame:[self headerViewFrame]];
    [self.headerView setButtonTargets:self selector:@selector(changeTabForButton:)];
    [self.tableView.tableHeaderView addSubview:self.headerView];
    
    self.tabActionBarView = [[UIView alloc] initWithFrame:[self tabActionBarViewMaxFrame]];
    [self.view addSubview:self.tabActionBarView];
    
    self.writeCommentView = [[UIView alloc] initWithFrame:[self writeCommentViewFrame]];
    [self.writeCommentView setBackgroundColor:[UIColor whiteColor]];
    [self.self.tabActionBarView addSubview:self.writeCommentView];
    
    self.commentField = [[UITextField alloc] initWithFrame:[self commentFieldFrame]];
    [self.commentField.layer setBorderColor:NavigationBarBlueColor.CGColor];
    [self.commentField.layer setBorderWidth:1.0];
    [self.commentField.layer setCornerRadius:5.0];
    [self.commentField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)]];
    [self.commentField setPlaceholder:@"Write comment"];
    [self.writeCommentView addSubview:self.commentField];
    
    self.commentSubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.commentSubmitButton setFrame:[self commentSubmitButtonFrame]];
    [self.commentSubmitButton addTarget:self action:@selector(writeComment) forControlEvents:UIControlEventTouchUpInside];
    self.commentSubmitButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
    [self.writeCommentView addSubview:self.commentSubmitButton];
    
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
    CGFloat topOffset = scrollView.contentOffset.y ;
//    NSLog(@"topoffset: %f",topOffset);
    CGFloat height = HeaderViewMaxHeight - topOffset;
    height = height < HeaderViewMinHeight ? HeaderViewMinHeight : height;
    CGFloat ratio = (height-HeaderViewMinHeight) / (HeaderViewMaxHeight - HeaderViewMinHeight);
    [self.headerView reorganizeForRatio:ratio];
    if(height == HeaderViewMinHeight){
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
    
//    NSLog(@"last point of header view: %f height: %f", topOffset + height, height);
    [self.tabActionBarView setFrame:CGRectByRatio([self tabActionBarViewMaxFrame], [self tabActionBarViewMinFrame], ratio)];
    if(ratio > 1.0){
        [self.tabBarController.tabBar setFrame:[self tabbarMaxFrame]];
    }else {
        [self.tabBarController.tabBar setFrame:CGRectByRatio([self tabbarMaxFrame], [self tabbarMinFrame], ratio)];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.decelerationRate);
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y != 0.0){
        return;
    }
//    NSLog(@"velocity: %f, %f",velocity.x,velocity.y);
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
    
    if(self.initiationType == SonicViewControllerInitiationTypeCommentWrite){
        [self.tableView setContentOffset:CGPointMake(0.0, HeaderViewMaxHeight - HeaderViewMinHeight)];
        [self setCurrentContentType:ContentTypeComments];
    }
    
    [self refreshContent];
    [self.headerView.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    [self.headerView.profileImageView setImage:[UIImage imageNamed:@"2013-11-07 09.52.53.jpg"]];
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
        [self setCurrentContentType:ContentTypeLikes];
    }
    else if(button.tag == CommentsTabButtonTag){
        [self setCurrentContentType:ContentTypeComments];
    }
    else if(button.tag == ResonicsTabButtonTag){
        [self setCurrentContentType:ContentTypeResonics];
    }
    [self.tableView reloadData];
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
//        [SNCAPIManager get]
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
    return 10;
    // Return the number of rows in the section.
    if([self currentContent]){
        return [[self currentContent] count];
    } else {
        return 0;
    }
}

- (void) writeComment
{

    [SNCAPIManager writeCommentToSonic:self.sonic withText:self.commentField.text withCompletionBlock:^(id object) {
        self.commentsContent = [self.commentsContent arrayByAddingObject:object];
        [self.tableView reloadData];
        [self.commentField setText:@""];
        [self closeKeyboard];
        //        [self refreshContent];
    } andErrorBlock:^(NSError *error) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    id currentObject = [[self currentContent] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"r: %d",indexPath.row]];
    if(currentContentType == ContentTypeLikes){
//        User* user = currentObject;
//        [cell.textLabel setText:user.username];
        
    } else if (currentContentType == ContentTypeComments){
//        SonicComment* comment = currentObject;
//        [cell.textLabel setText:comment.text];
    }
    return cell;
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
