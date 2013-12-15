//
//  UIButton+StateProperties.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/15/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "UIButton+StateProperties.h"

@implementation UIButton (StateProperties)

- (void)setBackgroundImageWithColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    UIImage* background = [self imageWithColor:backgroundColor];
    [self setBackgroundImage:background forState:state];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 88.0, 44.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end