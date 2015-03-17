//
//  SNCSplashView.h
//  Sonicraph
//
//  Created by Yunus Eren Guzel on 12/02/15.
//  Copyright (c) 2015 Yunus Eren Guzel. All rights reserved.
//

#import "CBZSplashView.h"
#import <UIKit/UIKit.h>

@interface SNCSplashView : UIView
@property CBZSplashView* splashView;
- (void) animate;
+(void)splash;
@end
