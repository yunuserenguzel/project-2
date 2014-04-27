//
//  SNCSwitchView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 25/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSwitchView.h"
#import "TypeDefs.h"
#import "Configurations.h"

@implementation SNCSwitchView

- (CGRect) onLabelFrame
{
    CGRect frame = [self frameWithZeroOrigin];
    frame.size.width -= self.imageView.frame.size.width;
    return frame;
}

- (CGRect) offLabelFrame
{
    CGRect frame = [self frameWithZeroOrigin];
    frame.size.width -= self.imageView.frame.size.width;
    frame.origin.x += self.imageView.frame.size.width;
    return frame;

}

- (CGRect) textLabelFrame
{
    return CGRectMake(100.0, 0.0, 240.0, 44.0);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (id) init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    self.backgroundColor = [UIColor clearColor];
    [self setUserInteractionEnabled:YES];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureFired:)];
    [self addGestureRecognizer:self.tapGesture];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0, 0.0, self.frame.size.height, self.frame.size.height)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self addSubview:self.imageView];
    
    _textLabel = [[UILabel alloc] initWithFrame:[self textLabelFrame]];
    [self.textLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.textLabel setTextColor:TabbarNonActiveButtonTintColor];
    [self addSubview:self.textLabel];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (CGRect) frameWithZeroOrigin
{
    return CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size = CGSizeMake(self.frame.size.height, self.frame.size.height);
    self.imageView.frame = imageViewFrame;
}

- (void) tapGestureFired:(UITapGestureRecognizer*)tapGesture
{
    if(self.on)
    {
        [self setOn:NO];
    }
    else
    {
        [self setOn:YES];
    }
}

 - (void)setOn:(BOOL)on
{
    _on = on;
    [UIView animateWithDuration:0.1 animations:^{
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if(on)
        {
            self.imageView.alpha = 1.0;
            self.textLabel.alpha = 1.0;
        }
        else
        {
            self.imageView.alpha = 0.5;
            self.textLabel.alpha = 0.5;
        }
    }];
}


@end
