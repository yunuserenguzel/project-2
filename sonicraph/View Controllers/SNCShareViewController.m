//
//  SNCShareControllerViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/7/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCShareViewController.h"
#import "SNCAPIManager.h"
#import "SonicPlayerView.h"
#import "UIButton+StateProperties.h"

@interface SNCShareViewController ()

@property UIButton* facebookButton;
@property UIButton* twitterButton;
@property UITextField* tagsField;
@property UIImageView* tags;
@property UIButton* tagsDoneButton;
@property UIBarButtonItem* shareButtonItem;
@property UIView* keyboardCloser;

@property SonicPlayerView* sonicPlayerView;

@end

@implementation SNCShareViewController
{
    BOOL keyboardIsShown;
}

- (CGRect) tagsFrame
{
    return CGRectMake(0.0, 420.0, 320.0, 44.0);
}
- (CGRect) tagsFieldFrame
{
    return CGRectMake(0.0, 0.0, 260.0, 44.0);
}
- (CGRect) tagsDoneButtonFrame
{
    return CGRectMake(260.0, 0.0, 60.0, 44.0);
}

- (CGRect) keyBoardCloserFrame
{
    return CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}


- (CGRect) twitterButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 44.0);
    frame.origin = CGPointMake(self.view.frame.size.width - frame.size.width, self.view.frame.size.height - frame.size.height);
    return frame;
}

- (CGRect) facebookButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 44.0);
    frame.origin = CGPointMake(0.0, self.view.frame.size.height - frame.size.height);
    return frame;
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.sonicPlayerView stop];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
	// Do any additional setup after loading the view.
    [self initializeShareButton];
    [self initializeFacebookAndTwitterButtons];
    [self initializeSonicPlayerView];
    [self initTags];
    [self configureViews];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:self.view.window];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:self.view.window];
}

- (void) configureViews
{
    if(![self isViewLoaded]){
        return;
    }
    [self.sonicPlayerView setSonic:self.sonic];
}

- (void) initializeSonicPlayerView
{
    self.sonicPlayerView = [[SonicPlayerView alloc]initWithFrame:[self sonicPlayerViewFrame]];
    [self.view addSubview:self.sonicPlayerView];
//    self.sonicPlayerView.backgroundColor = [UIColor whiteColor];
}

- (void) initTags
{
    self.tags = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AdCommentBoxWhite.png"]];
    [self.tags setFrame:[self tagsFrame]];
    [self.tags setUserInteractionEnabled:YES];
    [self.tags setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [self.view addSubview:self.tags];
    
    self.tagsField = [[UITextField alloc] initWithFrame:[self tagsFieldFrame]];
    [self.tagsField setKeyboardType:UIKeyboardTypeTwitter];
    [self.tagsField setPlaceholder:@"Add tags to your sonic..."];
    [self.tagsField setTintColor:[UIColor whiteColor]];
    [self.tagsField setTextColor:[UIColor whiteColor]];
    [self.tagsField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.tags addSubview:self.tagsField];
    
    self.tagsDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.tagsDoneButton.frame = [self tagsDoneButtonFrame];
    [self.tagsDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.tagsDoneButton setTintColor:[UIColor blackColor]];
    [self.tagsDoneButton addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.tags addSubview:self.tagsDoneButton];
}

- (void) closeKeyboard
{
    [self.keyboardCloser removeFromSuperview];
    [self.tagsField resignFirstResponder];
}

- (void) initializeFacebookAndTwitterButtons
{
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.twitterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebookButton setImage:[UIImage imageNamed:@"FacebookIcon.png"] forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"TwitterIcon.png"] forState:UIControlStateNormal];
    [self.twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    self.twitterButton.frame = [self twitterButtonFrame];
    self.facebookButton.frame = [self facebookButtonFrame];
    [@[self.twitterButton, self.facebookButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:button];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)];
        [button setBackgroundColor:[UIColor darkGrayColor]];
        [button.layer setBorderColor:[UIColor blackColor].CGColor];
        [button.layer setBorderWidth:1.0f];
        [button setTintColor:[UIColor lightGrayColor]];
        [button setAdjustsImageWhenHighlighted:NO];
        [button addTarget:self action:@selector(setClickedButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void) setClickedButtonSelected:(UIButton*)button
{
    if([button isSelected]){
        [button setSelected:NO];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    else {
        [button setSelected:YES];
        [button setTintColor:[UIColor whiteColor]];
    }
}

- (void) initializeShareButton
{
    self.shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Share.png"] style:UIBarButtonItemStyleDone target:self action:@selector(shareSonic)];
    [self.navigationItem setRightBarButtonItem:self.shareButtonItem];
}

- (void)setSonic:(SonicData *)sonic
{
    _sonic = sonic;
    [self.sonicPlayerView setSonic:sonic];
    [self configureViews];
}

- (void) shareSonic
{
    
    [SNCAPIManager createSonic:self.sonic withTags:self.tagsField.text withCompletionBlock:nil];
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillHide:(NSNotification *)n
{
//    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
//    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
//    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
//    viewFrame.size.height += keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.tags setFrame:[self tagsFrame]];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    self.keyboardCloser = [[UIView alloc] initWithFrame:[self keyBoardCloserFrame]];
//    [self.keyboardCloser setAlpha:0.0];
    [self.keyboardCloser setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.keyboardCloser addGestureRecognizer:tapGesture];
    [self.view addSubview:self.keyboardCloser];
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    CGRect frame = [self tagsFrame];
    frame.origin.y = self.view.frame.size.height - keyboardSize.height - frame.size.height;
    [self.tags setFrame:frame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:nil
                                                  object:nil];
}

@end
