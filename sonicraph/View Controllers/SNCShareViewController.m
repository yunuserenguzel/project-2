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
@property UIButton* twitterButton;
@property UITextField* tagsField;
@property UIImageView* tags;
@property UIButton* tagsDoneButton;
@property UIBarButtonItem* shareButtonItem;
@property UIView* keyboardCloser;
@property SonicPlayerView* sonicPlayerView;

@property UIButton* backButton;
@property UILabel* titleLabel;
@property UIButton* doneButton;

@end

@implementation SNCShareViewController
{
    BOOL keyboardIsShown;
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
    frame.size = CGSizeMake(110.0, 44.0);
    frame.origin = CGPointMake(105.0, self.view.frame.size.height - frame.size.height - 22.0);
    return frame;
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
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
}

- (void) configureViews
{
    if(![self isViewLoaded]){
        return;
    }
    [self.sonicPlayerView setSonic:self.sonic];
}
- (void) initializeTopViews
{
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:[self backButtonFrame]];
    [self.backButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
    [self.view addSubview:self.backButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    [self.titleLabel setText:@"Share"];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:self.backButton.titleLabel.font];
    [self.view addSubview:self.titleLabel];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:[self doneButtonFrame]];
    [self.doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.doneButton setImage:[UIImage imageNamed:@"Share.png"] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(shareSonic) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)];
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
    self.facebookSwitch = [[SNCSwitchView alloc] init];
    [self.facebookSwitch addTarget:self action:@selector(facebookButtonChanged:) forControlEvents:UIControlEventValueChanged];
    [self.facebookSwitch setFrame:[self facebookButtonFrame]];
    [self.facebookSwitch setImage:[UIImage imageNamed:@"FacebookShareButtonIcon.png"]];
    [self.facebookSwitch setBackgroundImage:[UIImage imageNamed:@"FacebookShareButtonBase.png"]];
    [self.view addSubview:self.facebookSwitch];
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
        // We will post on behalf of the user, these are the permissions we need:
    [SNCFacebookManager grantPermissionWithCompletionBlock:nil andErrorBlock:nil];
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
    [SNCAPIManager createSonic:self.sonic withTags:self.tagsField.text withCompletionBlock:^(Sonic *sonic) {
        
        // Make the request
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
   if (keyboardIsShown)
    {
        return;
    }
    self.keyboardCloser = [[UIView alloc] initWithFrame:[self keyBoardCloserFrame]];
    [self.keyboardCloser setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.keyboardCloser addGestureRecognizer:tapGesture];
    [self.view addSubview:self.keyboardCloser];
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
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
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:nil
     object:nil];
}

@end
