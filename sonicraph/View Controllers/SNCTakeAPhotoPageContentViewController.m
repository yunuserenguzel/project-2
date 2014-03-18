//
//  SNCTakeAPhotoPageContentViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCTakeAPhotoPageContentViewController.h"

@interface SNCTakeAPhotoPageContentViewController ()

@end

@implementation SNCTakeAPhotoPageContentViewController

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
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Take-A-Photo-Photo-.jpg"]];
    [imageView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:imageView];
    // Do any additional setup after loading the view.
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
