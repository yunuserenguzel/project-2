//
//  SNCGoThroughViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCGoThroughViewController.h"
#import "SNCTakeAPhotoPageContentViewController.h"
#import "SNCCaptureTheSoundPageContentViewController.h"
#import "SNCShareWithWorldPageContentViewController.h"
#import "SNCJoinNowPageContentViewController.h"

@interface SNCGoThroughViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property NSArray* contentViewControllers;

@end

@implementation SNCGoThroughViewController
{
    NSInteger currentIndex;
}

+ (SNCGoThroughViewController *)create
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:
                          [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                     forKey: UIPageViewControllerOptionSpineLocationKey];
    return [[SNCGoThroughViewController alloc]
            initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
            options:options];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    // Do any additional setup after loading the view.
    self.contentViewControllers = @[ [[SNCTakeAPhotoPageContentViewController alloc] init]
                                  ,[[SNCCaptureTheSoundPageContentViewController alloc] init]
                                  ,[[SNCShareWithWorldPageContentViewController alloc] init]
                                  ,[[SNCJoinNowPageContentViewController alloc] init]
                                 ];
    [self setViewControllers:[NSArray arrayWithObject:[self.contentViewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    for(int i=0;i<self.contentViewControllers.count ;i++)
    {
        if(viewController == [self.contentViewControllers objectAtIndex:i])
        {
            if(i+1 < self.contentViewControllers.count)
            {
                currentIndex = i+1;
                return [self.contentViewControllers objectAtIndex:i+1];
            }
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    for(int i=0;i<self.contentViewControllers.count ;i++)
    {
        if(viewController == [self.contentViewControllers objectAtIndex:i])
        {
            if(i-1 >= 0)
            {
                currentIndex = i-1;
                return [self.contentViewControllers objectAtIndex:i-1];
            }
        }
    }
    return nil;
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.contentViewControllers.count;
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return currentIndex;
}
//- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    return UIPageViewControllerSpineLocationMin;
//}


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
