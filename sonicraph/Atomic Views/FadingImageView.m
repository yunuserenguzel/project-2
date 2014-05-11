//
//  FadingImageView.m
//  Sonicraph
//
//  Created by Yunus Eren Guzel on 09/05/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "FadingImageView.h"
#define ARC4RANDOM_MAX      0x100000000
//
@implementation FadingImageView

-(void)setImageWithAnimation:(UIImage *)image
{
    [super setImage:image];

    CATransition *transition = [CATransition animation];
    
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    transition.duration = val * 0.10 + 0.10;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:.34 :.01 :.69 :1.57];
//    transition.type = kCATransitionFade;
    transition.type = kCATransitionMoveIn;
    [self.layer addAnimation:transition forKey:nil];

}

@end
