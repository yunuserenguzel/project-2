//
//  UIButton+StateProperties.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/15/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "UIButton+StateProperties.h"
#import "UIImage+scaleToSize.h"

@implementation UIButton (StateProperties)

- (void)setBackgroundImageWithColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    UIImage* background = [UIImage imageWithColor:backgroundColor withSize:CGSizeMake(44.0, 44.0)];
    [self setBackgroundImage:background forState:state];
    
}


@end