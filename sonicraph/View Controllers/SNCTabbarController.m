//
//  SNCTabbarController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/15/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCTabbarController.h"
#import "UIButton+StateProperties.h"

#import "Configurations.h"
#import "SNCGoThroughViewController.h"
#import "SNCAppDelegate.h"

#define CameraTabbarIndex 2

static int previousTabIndex = 0;

@interface SNCTabbarController () <UIGestureRecognizerDelegate,UITabBarControllerDelegate>

@end

@implementation SNCTabbarController
{
    UIView* cameraItemBackground;
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
//    if(previousTabIndex == tabBarController.selectedIndex)
//    {
//        NSLog(@"I'm here");
//    }
//    previousTabIndex = tabBarController.selectedIndex;
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    int currentIndex = [tabBar.items indexOfObject:item];
    if(previousTabIndex == currentIndex)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTabbarItemReSelected object:[NSNumber numberWithInt:currentIndex]];
    }
    if(currentIndex != CameraTabbarIndex)
    {
        previousTabIndex = currentIndex;
    }
}

- (void) openPreviousTab
{
    [self setSelectedIndex:previousTabIndex];
}
//
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self.tabBar setBarStyle:UIBarStyleDefault];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    [self.tabBar setTintColor:MainThemeColor];
    [self.tabBar setSelectedImageTintColor:MainThemeColor];
    self.tabBar.backgroundColor = [UIColor clearColor];
    [[self.tabBar.subviews objectAtIndex:0] setAlpha:0.1];
    self.tabBar.superview.backgroundColor = [UIColor clearColor];
    [self.tabBar.layer setBackgroundColor:[UIColor clearColor].CGColor];
    self.tabBar.superview.superview.backgroundColor = [UIColor clearColor];
    for (UIView* view in self.tabBar.subviews) {
        [view setBackgroundColor:[UIColor clearColor]];
    }
    
    [self configureTabbarItems];
    
    [self setDelegate:self];
    [self setSelectedIndex:0];
    
    [[SNCAppDelegate sharedInstance] updateDeviceToken];
}

- (void) configureTabbarItems
{
    NSArray* selectedImageNames = @[@"homeactive.png",
                                    @"searchactive.png",
                                    @"cameraactive.png",
                                    @"notificationsactive.png",
                                    @"profileactive.png"];
    NSArray*imageNames  = @[@"home.png",
                            @"search.png",
                            @"camera.png",
                            @"notifications.png",
                            @"profile.png"];
    //    NSLog(@"tabbar height: %f",self.tabBar.frame.size.height);
    for(int i=0; i<self.tabBar.items.count; i++)
    {
        UITabBarItem* item = [self.tabBar.items objectAtIndex:i];
        [item setTitle:nil];
        [item setImageInsets:UIEdgeInsetsMake(5.0, 0.0, -5.0, 0.0)];
        if(i == 1)
        {
            [item setImageInsets:UIEdgeInsetsMake(6.0, -2.0, -6.0, 2.0)];
        }
        [item setImage:[[UIImage imageNamed:[imageNames objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item setSelectedImage:[[UIImage imageNamed:[selectedImageNames objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        if([item.title isEqualToString:@"Camera"])
//        {
//            [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NavigationBarBlueColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
//        }
    }
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:MainThemeColor, NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateSelected];

}

- (void) removeCameraViewController:(UIViewController*)viewController
{
    NSMutableArray* mutableViewControllers = [self.viewControllers mutableCopy];
    [mutableViewControllers removeObject:viewController];
    
    UINavigationController* navigation = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraContainerController"];
    [mutableViewControllers insertObject:navigation atIndex:CameraTabbarIndex];
    self.viewControllers = [NSArray arrayWithArray:mutableViewControllers];
    [self configureTabbarItems];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)dealloc
{
//    NSLog(@"tabbar dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
