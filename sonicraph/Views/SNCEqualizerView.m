//
//  SNCEqualizerView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 13/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCEqualizerView.h"

#define ARC4RANDOM_MAX  0x100000000

#define BarCount 3

typedef void (^CompletionBoolBlock) (BOOL successful);

@interface SNCEqualizerView ()

@property NSArray* bars;

@end

@implementation SNCEqualizerView
{
    BOOL shouldAnimate;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self setFrame:frame];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    self.alpha = 0.0;
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:BarCount];
    for(int i=0; i< BarCount; i++)
    {
        [array addObject:[UIView new]];
    }
    self.bars = [array mutableCopy];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat barHeight = frame.size.height;
    CGFloat barWidth = frame.size.width / (BarCount * 2 - 1);
    for(int i=0; i< self.bars.count; i++)
    {
        UIView* bar = [self.bars objectAtIndex:i];
        CGRect barFrame = CGRectZero;
        barFrame.size.height = barHeight;
        barFrame.size.width = barWidth;
        barFrame.origin.y = 0.0;
        barFrame.origin.x = barWidth * (i * 2);
        [bar setFrame:barFrame];
        [bar setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:bar];
    }
}

- (void)startAnimating
{
    if(shouldAnimate)
    {
        return;
    }
    shouldAnimate = YES;
    self.alpha = 1.0;
    [self normalizeWithAnimationWithCompletionBlock:^(BOOL successful) {
        [self randomizeWithAnimation];
    }];
}

- (void)stopAnimating
{
    shouldAnimate = NO;
    [self normalizeWithAnimationWithCompletionBlock:^(BOOL successful) {
        self.alpha = 0.0;
    }];
}

- (void) normalizeWithAnimationWithCompletionBlock:(CompletionBoolBlock) animation
{
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView* bar in self.bars) {
            [self setHeight:self.frame.size.height * 0.5 forBar:bar];
        }
    } completion:animation];
}

- (void) setHeight:(CGFloat)height forBar:(UIView*)bar
{
    CGRect barFrame = bar.frame;
    barFrame.origin.y = self.frame.size.height - height;
    barFrame.size.height = height;
    bar.frame = barFrame;
}

- (double) randomHeight
{
    return ((double)arc4random() / ARC4RANDOM_MAX) * self.frame.size.height;
}

- (void) randomizeWithAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        for (int i=0; i< self.bars.count;i++) {
            UIView* bar = [self.bars objectAtIndex:i];
            CGFloat height = [self randomHeight] * 0.5;
            height = i%2==0 ? height + self.frame.size.height * 0.5 : height;
            [self setHeight:height forBar:bar];
        }
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:0.4 animations:^{
           for (int i=0; i< self.bars.count;i++) {
               UIView* bar = [self.bars objectAtIndex:i];
               CGFloat height = [self randomHeight] * 0.5;
               height = i%2==1 ? height + self.frame.size.height * 0.5 : height;
               [self setHeight:height forBar:bar];
           }
       } completion:^(BOOL finished) {
           if(shouldAnimate)
           {
               [self randomizeWithAnimation];
           }
       }];
    }];
}




@end
