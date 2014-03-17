//
//  SNCSwitchView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 25/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSwitchView.h"
#import "TypeDefs.h"

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
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 180.0, 44.0)];
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
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self.backgroundImageView setContentMode:UIViewContentModeCenter];
    [self addSubview:self.backgroundImageView];
    
    _onLabel = [[UILabel alloc] initWithFrame:[self onLabelFrame]];
    [self.onLabel setText:@"On"];
    [self.onLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.onLabel];
    
    _offLabel = [[UILabel alloc] initWithFrame:[self offLabelFrame]];
    [self.offLabel setText:@"Off"];
    [self.offLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.offLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.height, self.frame.size.height)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self addSubview:self.imageView];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureFired:)];
    [self.imageView addGestureRecognizer:self.panGesture];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
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
    [self.backgroundImageView setFrame:[self frameWithZeroOrigin]];
    [self.onLabel setFrame:[self onLabelFrame]];
    [self.offLabel setFrame:[self offLabelFrame]];
//    [self.layer setCornerRadius:self.frame.size.height * 0.5];
//    [self.imageView.layer setCornerRadius:self.frame.size.height * 0.5];
//    [self calculateAlphaForImageView];
}

//- (void) calculateAlphaForImageView
//{
//    CGFloat ratio = self.imageView.frame.origin.x / (self.frame.size.width-self.imageView.frame.size.width);
//    self.imageView.alpha = (ratio * 0.5) + 0.5;
//}

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
    CGFloat targetX = 0.0;
    if(on)
    {
        targetX = self.frame.size.width - self.imageView.frame.size.width;
    }
    [UIView animateWithDuration:0.1 animations:^{
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.origin.x = targetX;
        self.imageView.frame = imageViewFrame;
//        [self calculateAlphaForImageView];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if(on)
        {
            [self.onLabel setAlpha:1.0];
            [self.offLabel setAlpha:0.0];
        }
        else
        {
            [self.onLabel setAlpha:0.0];
            [self.offLabel setAlpha:1.0];
        }
    }];
}

- (void) panGestureFired:(UIPanGestureRecognizer*)panGesture
{
    CGPoint currentLocation = [panGesture locationInView:self];
    if(panGesture.state == UIGestureRecognizerStateEnded)
    {
        
    }
    else
    {
        CGRect imageViewFrame = self.imageView.frame;
        if(currentLocation.x - imageViewFrame.size.width * 0.5 >= 0 && currentLocation.x + imageViewFrame.size.width * 0.5 <= self.frame.size.width)
        {
            imageViewFrame.origin.x = currentLocation.x - imageViewFrame.size.width * 0.5;
            self.imageView.frame = imageViewFrame;
//            [self calculateAlphaForImageView];
        }
    }
    if(currentLocation.x > self.frame.size.width * 0.5)
    {
        [self setOn:YES];
    }
    else
    {
        [self setOn:NO];
    }
}



@end
