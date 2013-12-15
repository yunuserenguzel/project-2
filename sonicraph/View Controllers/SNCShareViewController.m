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

@interface SNCShareViewController ()

@property UIButton* facebookButton;
@property UIButton* twitterButton;
@property UITextField* tagsField;
@property UIBarButtonItem* shareButtonItem;

@property SonicPlayerView* sonicPlayerView;

@end

@implementation SNCShareViewController


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
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
	// Do any additional setup after loading the view.
    [self initializeShareButton];
    [self initializeFacebookAndTwitterButtons];
    [self initializeSonicPlayerView];
    [self configureViews];
    
    [self.view.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        view.layer.borderColor = [UIColor redColor].CGColor;
        view.layer.borderWidth = 2.0f;
    }];
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
    self.sonicPlayerView.backgroundColor = [UIColor whiteColor];
}

- (void) initializeFacebookAndTwitterButtons
{
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.twitterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebookButton setImage:[UIImage imageNamed:@"FacebookWhite.png"] forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"Twitter.png"] forState:UIControlStateNormal];
    [self.twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    self.twitterButton.frame = [self twitterButtonFrame];
    self.facebookButton.frame = [self facebookButtonFrame];
    [@[self.twitterButton, self.facebookButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:button];
        [button setBackgroundColor:[UIColor darkGrayColor]];
        [button.layer setBorderColor:[UIColor blackColor].CGColor];
        [button.layer setBorderWidth:1.0f];
        [button setTintColor:[UIColor whiteColor]];
    }];
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
    
    [SNCAPIManager createSonic:self.sonic withCompletionBlock:^(Sonic* sonic) {
        
    }];
    
    [self.tabBarController setSelectedIndex:2];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
