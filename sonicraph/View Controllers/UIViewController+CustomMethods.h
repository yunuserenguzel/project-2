//
//  SNCDefautViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 16/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CustomMethods)

- (CGFloat) heightOfNavigationBar;
- (CGRect) frameForScrollContent;
- (UIEdgeInsets) edgeInsetsForScrollContent;

@end
