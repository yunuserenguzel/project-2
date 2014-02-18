//
//  SNCNavigationViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 17/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCNavigationViewController.h"
#import "Configurations.h"

@interface SNCNavigationViewController ()

@end

@implementation SNCNavigationViewController

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
	// Do any additional setup after loading the view.
    [self.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBarTintColor:PinkColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
