//
//  SNCSoundSlider.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/18/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCSoundSlider : UIView

@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;
@property (nonatomic) CGFloat value;

@property (nonatomic) UIColor* fillColor;
@property (nonatomic) UIColor* baseColor;

@end
