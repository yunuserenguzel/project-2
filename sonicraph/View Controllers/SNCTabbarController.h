//
//  SNCTabbarController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/15/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCTabbarController : UITabBarController

+ (SNCTabbarController*) sharedInstance;

- (void) openPreviousTab;

@end
