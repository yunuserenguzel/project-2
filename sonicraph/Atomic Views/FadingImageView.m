//
//  FadingImageView.m
//  Sonicraph
//
//  Created by Yunus Eren Guzel on 09/05/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "FadingImageView.h"

@implementation FadingImageView

-(void)setImageWithAnimation:(UIImage *)image
{
    [super setImage:image];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
//    transition.type = kCATransitionMoveIn;
    [self.layer addAnimation:transition forKey:nil];

}

@end
