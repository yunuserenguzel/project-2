//
//  SNCGetStartedPageContentViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 22/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCGetStartedPageContentViewController.h"
#import "SNCGoThroughViewController.h"

@interface SNCGetStartedPageContentViewController ()

@property UIButton* button;

@end

@implementation SNCGetStartedPageContentViewController
- (CGRect) getStartedButtonFrame
{
    return CGRectMake(5.0, self.view.frame.size.height - 210.0, 310.0, 50.0);
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:[self getStartedButtonFrame]];
    [self.button setImage:[UIImage imageNamed:@"gothrough_getstartedbutton.png"] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(getStarted) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    // Do any additional setup after loading the view.
}

- (void) getStarted
{
    SNCGoThroughViewController* goThrough = (SNCGoThroughViewController*)self.parentViewController;
    [goThrough startGoThrough];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
