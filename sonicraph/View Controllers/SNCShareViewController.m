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
#import <FacebookSDK/FacebookSDK.h>
#import "Configurations.h"
#import "SNCSwitchView.h"
#import "SNCAppDelegate.h"
#import "SNCFacebookManager.h"

#define FacebookShareDefaultValueKey @"FacebookShareDefaultValueKey" 

@interface SNCShareViewController ()

@property SNCSwitchView* facebookSwitch;
@property SNCResizableTextView* tagsTextView;
@property UIBarButtonItem* shareButtonItem;
@property UIView* keyboardCloser;
@property SonicPlayerView* sonicPlayerView;

@property UIButton* backButton;
@property UILabel* titleLabel;
@property UIButton* doneButton;

@property UIActivityIndicatorView* activityIndicator;

@property UITapGestureRecognizer* tapGesture;

@property UILabel* shareOnFacebook;

@end

@implementation SNCShareViewController
{
    BOOL keyboardIsShown;
    UIImage* textFieldBackgroundPassiveImage;
    UIImage* textFieldBackgroundActiveImage;
    CGFloat keyboardHeight;
}
- (CGRect) backButtonFrame
{
    return CGRectMake(0.0, 0.0, 106.0, 66.0);
}
- (CGRect) titleLabelFrame
{
    return CGRectMake(106.0, 0.0, 108.0, 66.0);
}

- (CGRect) doneButtonFrame
{
    return CGRectMake(106.0 + 108.0, 0.0, 106.0, 66.0);
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
}

- (CGRect) tagsFrame
{
    return CGRectMake(0.0, 390.0, 320.0, 44.0);
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
    frame.size = CGSizeMake(320.0, 44.0);
    frame.origin = CGPointMake(0.0, self.view.frame.size.height - 44.0);
    return frame;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.sonicPlayerView stop];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:CameraViewControllersBackgroundColor];
    
	// Do any additional setup after loading the view.
    [self initializeFacebookAndTwitterButtons];
    [self initializeSonicPlayerView];
    [self initTags];
    [self configureViews];
    [self initializeTopViews];
    
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
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.facebookSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:FacebookShareDefaultValueKey] boolValue];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setFrame:[self sonicPlayerViewFrame]];
    [self.view addSubview:self.activityIndicator];
    [[self activityIndicator] startAnimating];
}

- (void) configureViews
{
    if(![self isViewLoaded]){
        return;
    }
    [self.doneButton setEnabled:YES];
    [self.sonicPlayerView setSonic:self.sonic];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}
- (void) initializeTopViews
{
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:[self backButtonFrame]];
    [self.backButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
    [self.view addSubview:self.backButton];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:[self doneButtonFrame]];
    [self.doneButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.doneButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.doneButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 76.0, 0.0, 0.0)];
    [self.doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 38.0)];
    [self.doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.doneButton setImage:[UIImage imageNamed:@"Share.png"] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(shareSonic) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setEnabled:NO];
    [self.view addSubview:self.doneButton];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) initializeSonicPlayerView
{
    self.sonicPlayerView = [[SonicPlayerView alloc]initWithFrame:[self sonicPlayerViewFrame]];
    [self.view addSubview:self.sonicPlayerView];
    [self.sonicPlayerView.longPressGesture setDelegate:self];
    [self.sonicPlayerView.tapGesture setDelegate:self];
}

- (void) initTags
{
    self.keyboardCloser = [[UIView alloc] initWithFrame:[self keyBoardCloserFrame]];
    [self.view addSubview:self.keyboardCloser];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.keyboardCloser addGestureRecognizer:self.tapGesture];
    [self.keyboardCloser setHidden:YES];
    
    self.tagsTextView = [[SNCResizableTextView alloc] initWithFrame:[self tagsFrame]];
    self.tagsTextView.delegate = self;
    self.tagsTextView.backgroundColor = self.view.backgroundColor;
    [self.tagsTextView.growingTextView setPlaceholder:@"Add tags"];
    [self.view addSubview:self.tagsTextView];
    [self.tagsTextView.doneButton setImage:[UIImage imageNamed:@"AddTagIcon.png"] forState:UIControlStateNormal];
}

- (void)SNCResizableTextView:(SNCResizableTextView *)textView willChangeHeight:(float)height
{
    CGRect frame = [self tagsFrame];
    frame.size.height = height;
    CGFloat bottom = MIN(([[UIScreen mainScreen] bounds].size.height - keyboardHeight), frame.origin.y+frame.size.height) ;
    frame.origin.y = bottom - frame.size.height;
    [self.tagsTextView setFrame:frame];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) closeKeyboard
{
    [self.tagsTextView.growingTextView resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapGesture];
}

- (void) initializeFacebookAndTwitterButtons
{
    self.facebookSwitch = [[SNCSwitchView alloc] init];
    [self.facebookSwitch addTarget:self action:@selector(facebookButtonChanged:) forControlEvents:UIControlEventValueChanged];
    [self.facebookSwitch setFrame:[self facebookButtonFrame]];
    [self.facebookSwitch setImage:[UIImage imageNamed:@"facebook_share_button.png"]];
    [self.facebookSwitch setBackgroundColor:[UIColor whiteColor]];
    [self.facebookSwitch.textLabel setText:@"Share On Facebook"];
    [self.view addSubview:self.facebookSwitch];
//    
//    self.shareOnFacebook = [[UILabel alloc] initWithFrame:[self shareOnFacebookFrame]];
//    [self.shareOnFacebook setText:@"Share on facebook"];
//    [self.shareOnFacebook setFont:[UIFont systemFontOfSize:12.0]];
//    [self.shareOnFacebook setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6]];
//    [self.shareOnFacebook setTextAlignment:NSTextAlignmentCenter];
//    [self.view addSubview:self.shareOnFacebook];
    
}

- (void) facebookButtonChanged:(SNCSwitchView*)switchView
{
    if(self.facebookSwitch.on)
    {
        [self enableFacebook];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.facebookSwitch.on] forKey:FacebookShareDefaultValueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) enableFacebook
{
    [SNCFacebookManager grantPermissionWithCompletionBlock:^(id object) {
        
    } andErrorBlock:^(NSError *error) {
        self.facebookSwitch.on = NO;
    }];
}

- (void) setClickedButtonSelected:(UIButton*)button
{
    if([button isSelected])
    {
        [button setSelected:NO];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    else
    {
        [button setSelected:YES];
        [button setTintColor:[UIColor whiteColor]];
    }
}


- (void)setSonic:(SonicData *)sonic
{
    _sonic = sonic;
    [self.sonicPlayerView setSonic:sonic];
    [self configureViews];
}

- (void) shareSonic
{
    [SNCAPIManager createSonic:self.sonic withTags:self.tagsTextView.growingTextView.text withCompletionBlock:^(Sonic *sonic) {
        if(self.facebookSwitch.on)
        {
            [SNCFacebookManager postSonic:sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }];
    
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
    
    keyboardIsShown = NO;
    [self.keyboardCloser setHidden:YES];
    NSNumber *duration = [n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [n.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration floatValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    [self.tagsTextView setBackgroundColor:self.view.backgroundColor];
    keyboardHeight = 0;
    [self SNCResizableTextView:self.tagsTextView willChangeHeight:self.tagsTextView.frame.size.height];
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)n
{
   if (keyboardIsShown)
    {
        return;
    }
    [self.keyboardCloser setHidden:NO];
    
    NSNumber *duration = [n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [n.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    //    [self.view addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)]];
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration floatValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.tagsTextView setBackgroundColor:rgb(235, 235, 235)];
    // The kKeyboardAnimationDuration I am using is 0.3
    [self SNCResizableTextView:self.tagsTextView willChangeHeight:self.tagsTextView.frame.size.height];
    
    [UIView commitAnimations];
    
    keyboardIsShown = YES;

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:nil
     object:nil];
}

@end
