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
    NSArray *permissionsNeeded = @[@"publish_actions"];
    if([[FBSession activeSession] state] == FBSessionStateOpen || [[FBSession activeSession] state] == FBSessionStateOpenTokenExtended)
    {
        // Request the permissions the user currently has
        [FBRequestConnection
         startWithGraphPath:@"/me/permissions"
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error){
                 NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                 NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                 
                 // Check if all the permissions we need are present in the user's current permissions
                 // If they are not present add them to the permissions to be requested
                 for (NSString *permission in permissionsNeeded){
                     if (![currentPermissions objectForKey:permission]){
                         [requestPermissions addObject:permission];
                     }
                 }
                 
                 // If we have permissions to request
                 if ([requestPermissions count] > 0){
                     // Ask for the missing permissions
                     [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                           defaultAudience:FBSessionDefaultAudienceFriends
                                                         completionHandler:^(FBSession *session, NSError *error) {
                                                             if (!error) {
                                                                 // Permission granted, we can request the user information
                                                                 //                                                                                      [self makeRequestToShareLink];
                                                             } else {
                                                                 // An error occurred, handle the error
                                                                 // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                 NSLog(@"%@", error.description);
                                                             }
                                                         }];
                 }
                 else
                 {
                     // Permissions are present, we can request the user information
                     //                                          [self makeRequestToShareLink];
                 }
                 
             } else {
                 // There was an error requesting the permission information
                 // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                 NSLog(@"%@", error.description);
             }
         }];
    }
    else
    {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             if(state == FBSessionStateOpenTokenExtended || state == FBSessionStateOpen)
             {
                 [self enableFacebook];
             }
             // Retrieve the app delegate
             SNCAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
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
            NSString* sonicPageLink = [NSString stringWithFormat:@"https://sonicraph.herokuapp.com/sonic?s=%@",sonic.sonicId];
            NSString* fullNameFild = [NSString stringWithFormat:@"%@ took a sonic", sonic.owner.fullName];
            NSString* name = sonic.tags ? sonic.tags : @"Sonicraph";
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           name, @"name",
                                           fullNameFild, @"caption",
                                           @"sonicraph.com", @"description",
                                           sonicPageLink, @"link",
                                           nil];
            
            // Make the request
            [FBRequestConnection startWithGraphPath:@"/me/feed"
                                         parameters:params
                                         HTTPMethod:@"POST"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          // Link posted successfully to Facebook
                                          NSLog(@"result: %@", result);
                                      } else {
                                          // An error occurred, we need to handle the error
                                          // See: https://developers.facebook.com/docs/ios/errors
                                          NSLog(@"%@", error.description);
                                      }
                                  }];
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
    if (keyboardIsShown)
    {
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
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:nil
     object:nil];
}

@end
