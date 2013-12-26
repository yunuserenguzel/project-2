//
//  SNCSoundSlider.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/18/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSoundSlider.h"
#import <QuartzCore/QuartzCore.h>

@interface SNCSoundSlider ()

@property UIView* fillView;

@end

@implementation SNCSoundSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initViews];
    }
    return self;
}

- (id) init
{
    if (self = [super init]){
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    self.minimumValue = 0.0;
    self.maximumValue = 0.0;
    self.value = 0.0;
    self.fillView = [[UIView alloc] init];
    [self addSubview:self.fillView];
    [self.fillView setHidden:YES];
    [self.fillView.layer setShadowColor:[UIColor redColor].CGColor];
    [self.fillView.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [self.fillView.layer setShadowOpacity:1.0f];
    [self.fillView.layer setShadowRadius:1.0f];
    [self setFillColor:[UIColor redColor]];
    [self setBaseColor:[UIColor clearColor]];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self.fillView setBackgroundColor:fillColor];
}

- (void) setBaseColor:(UIColor *)baseColor
{
    _baseColor= baseColor;
    [self setBackgroundColor:baseColor];
}

- (void) setMinimumValue:(CGFloat)minimumValue
{
    _minimumValue = minimumValue;
    [self setValue:self.value];
}

- (void) setMaximumValue:(CGFloat)maximumValue
{
    _maximumValue = maximumValue;
    [self setValue:self.value];
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    CGFloat min = self.minimumValue;
    CGFloat max = self.maximumValue;
    if (value == 0.0){
        [self.fillView setHidden:YES];
    }
    else if (value > min && value <= max && max > min){
        [self.fillView setHidden:NO];
        [self.fillView setFrame:CGRectMake(0.0, 0.0, self.frame.size.width * (value) / (max - min), self.frame.size.height)];
    }
//    else {
//        [UIView animateWithDuration:0.5 animations:^{
//            [self.fillView setAlpha:0.0];
//        } completion:^(BOOL finished) {
//            [self.fillView setHidden:YES];
//            [self.fillView setAlpha:1.0];
//        }];
//    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect fillFrame = self.fillView.frame;
    fillFrame.size.height = frame.size.height;
    [self.fillView setFrame:fillFrame];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
