//
//  SNCGoThroughViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

UIView* textFieldWithBaseAndLabel(UITextField*);


@interface SNCGoThroughViewController : UIPageViewController

+ (SNCGoThroughViewController*) create;

- (void) showViewController:(UIViewController*)viewController;

- (void) showRegisterViewController;

- (void) showLoginViewController;
@end
