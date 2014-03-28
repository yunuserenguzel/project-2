//
//  TypeDefs2.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/15/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "TypeDefs.h"

UIColor* rgb(CGFloat red, CGFloat green, CGFloat blue){
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}


CGRect CGRectByRatio(CGRect maxRect, CGRect minRect, CGFloat ratio)
{
    CGRect rect = CGRectZero;
    
    rect.origin.x = (maxRect.origin.x - minRect.origin.x)*ratio + minRect.origin.x;
    rect.origin.y = (maxRect.origin.y - minRect.origin.y)*ratio + minRect.origin.y;
    rect.size.width = (maxRect.size.width - minRect.size.width)*ratio + minRect.size.width;
    rect.size.height = (maxRect.size.height - minRect.size.height)*ratio + minRect.size.height;
    
    return rect;
}

