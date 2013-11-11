//
//  SNCShareControllerViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/7/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCShareViewController.h"
#import "SNCAPIManager.h"

@interface SNCShareViewController ()

@property UIButton* shareButton;

@end

@implementation SNCShareViewController

- (CGRect) shareButtonFrame
{
    return CGRectMake(50.0, 200.0, 100.0, 50.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeShareButton];
}

- (void) initializeShareButton
{
    self.shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.shareButton setFrame:[self shareButtonFrame]];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareSonic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
}

- (void) shareSonic
{
    NSLog(@"Should share to server");
    
    [SNCAPIManager createSonic:self.sonic withCompletionBlock:^(NSDictionary *responseDictionary) {
        [SNCAPIManager getMySonicsWithCompletionBlock:nil];
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
