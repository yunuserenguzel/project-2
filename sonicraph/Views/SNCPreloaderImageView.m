//
//  SNCPreloaderImageView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 15/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCPreloaderImageView.h"

@implementation SNCPreloaderImageView

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
    if(self = [super init])
    {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    NSMutableArray* images = [[NSMutableArray alloc] initWithCapacity:30];
    for(int i=0;i < 30;i++)
    {
        NSString* imageName;
        if(i < 10)
        {
            imageName = [NSString stringWithFormat:@"Preloader_10_0000%d.png",i];
        }
        else
        {
            imageName = [NSString stringWithFormat:@"Preloader_10_000%d.png",i];
        }
        [images addObject:[UIImage imageNamed:imageName]];
    }
    self.animationImages = images;
    self.animationDuration = 1.0;
    self.animationRepeatCount = 0;
    [self startAnimating];
}

 -(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if(hidden)
    {
        [self stopAnimating];
    }
    else
    {
        [self startAnimating];
    }
}

@end
