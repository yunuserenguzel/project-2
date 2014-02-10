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


#define CameraTabbarIndex 1

static SNCTabbarController* sharedInstance;
static int previousTabIndex = 0;

@interface SNCTabbarController () <UIGestureRecognizerDelegate,UITabBarControllerDelegate>

@end

@implementation SNCTabbarController
{
    UIView* cameraItemBackground;
}
+ (SNCTabbarController *)sharedInstance
{
    return sharedInstance;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    previousTabIndex = tabBarController.selectedIndex;
    return YES;
}

- (void)openPreviousTab
{
    [self setSelectedIndex:previousTabIndex];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedInstance = self;

    [self.tabBar setBarStyle:UIBarStyleDefault];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    [self.tabBar setTintColor:NavigationBarBlueColor];
    [self.tabBar setSelectedImageTintColor:PinkColor];
    self.tabBar.backgroundColor = [UIColor clearColor];
    [[self.tabBar.subviews objectAtIndex:0] setAlpha:0.1];
    self.tabBar.superview.backgroundColor = [UIColor clearColor];
    [self.tabBar.layer setBackgroundColor:[UIColor clearColor].CGColor];
    self.tabBar.superview.superview.backgroundColor = [UIColor clearColor];
    for (UIView* view in self.tabBar.subviews) {
        [view setBackgroundColor:[UIColor clearColor]];
    }
    
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:PinkColor, NSForegroundColorAttributeName, nil]
//                                             forState:UIControlStateNormal];
    
//    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem* item, NSUInteger idx, BOOL *stop) {
//    }];
    
    [self setDelegate:self];
    [self setSelectedIndex:0];
    
//    cameraItemBackground = [[UIView alloc] initWithFrame:CGRectMake(160.0-44.0, 0.0, 88.0, 49.0)];
//    [cameraItemBackground setBackgroundColor:[UIColor whiteColor]];
//
//    
//    [self.tabBar.subviews enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
//        NSLog(@"view: %@",button);
//        if(idx == CameraTabbarIndex){
//            [button addSubview:cameraItemBackground];
//            UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonPressed:)];
//            [gesture setMinimumPressDuration:0.0];
//            [gesture setDelegate:self];
//            [button addGestureRecognizer:gesture];
//            
//            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTapped)];
//            [button addGestureRecognizer:tapGesture];
//        }
//    }];
//    
//    [self.tabBar insertSubview:cameraItemBackground atIndex:0];
}

//- (void) cameraButtonPressed:(UILongPressGestureRecognizer*)recognizer
//{
//    if([recognizer state] == UIGestureRecognizerStateBegan){
//        [cameraItemBackground setBackgroundColor:[UIColor lightGrayColor]];
//        
//    }
//    else if ([recognizer state] == UIGestureRecognizerStateEnded){
//        [cameraItemBackground setBackgroundColor:[UIColor greenColor]];
//    
//    }
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
//
//- (void) cameraButtonTapped
//{
//    previousTabIndex = self.selectedIndex;
//    [self setSelectedIndex:CameraTabbarIndex];
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
