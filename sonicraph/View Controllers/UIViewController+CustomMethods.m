//
//  SNCDefautViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 16/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "UIViewController+CustomMethods.h"
#import "TypeDefs.h"
#import "Configurations.h"

@interface UIViewController ()

@end

@implementation UIViewController (CustomMethods)

- (CGFloat) heightOfNavigationBar
{
    return self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (CGRect) frameForScrollContent
{
    return CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - [self heightOfNavigationBar] );
}
- (UIEdgeInsets)edgeInsetsForScrollContent
{
    return UIEdgeInsetsMake(0.0, 0.0, self.tabBarController.tabBar.frame.size.height, 0.0);
}
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setBarTintColor:PinkColor];
//    
//}
@end
