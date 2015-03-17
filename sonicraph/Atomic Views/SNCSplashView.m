//
//  SNCSplashView.m
//  Sonicraph
//
//  Created by Yunus Eren Guzel on 12/02/15.
//  Copyright (c) 2015 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSplashView.h"
#import "Configurations.h"

static SNCSplashView* splashView = nil;
@implementation SNCSplashView
{
    UIImageView* splashIconView;
    UIWindow* window;
}

+ (void) splash
{
    splashView = [[SNCSplashView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:splashView];
    [splashView animate];
}

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGFloat radius = 15;
    [path addArcWithCenter:CGPointMake(radius, radius)
                    radius:radius
                startAngle:0.0
                  endAngle:2.0 * M_PI
                 clockwise:NO];
    [path fill];
    
    CBZSplashView *splashView = [CBZSplashView splashViewWithBezierPath:path
                                                        backgroundColor:MainThemeColor];
    UIImage* splashIcon = [UIImage imageNamed:@"sonic_icon.png"];
    splashIconView = [[UIImageView alloc] initWithFrame:CGRectMake(68.0, 184.0, splashIcon.size.width, splashIcon.size.height)];
    splashIconView.image = splashIcon;
    [splashView addSubview:splashIconView];
    

    splashView.iconStartSize = splashIcon.size;
    splashView.animationDuration = 1.2;
    
    [self addSubview:splashView];
    
    self.splashView = splashView;
}

- (void)animate
{
    /* wait a beat before animating in */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.6 animations:^{
            splashIconView.alpha = 0.0;
        }];
        [self.splashView startAnimationWithCompletionHandler:^{
            [self removeFromSuperview];
        }];
    });
}

@end
