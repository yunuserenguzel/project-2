//
//  SonicCollectionView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/5/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicCollectionViewCell.h"
#import "SonicData.h"
#import "Configurations.h"

@implementation SonicCollectionViewCell

- (CGRect) imageViewFrame
{
    return CGRectMake(0.0, 0.0, SonicCollectionViewCellSize.width, SonicCollectionViewCellSize.height);
}

- (CGRect) resonicImageViewFrame
{
    return CGRectMake(SonicCollectionViewCellSize.width - 28.0,SonicCollectionViewCellSize.height - 25.0, 20.0 ,20.0);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor whiteColor]];
        self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self imageViewFrame]];
        [self.sonicPlayerView setUserInteractionEnabled:NO];
        [self.contentView addSubview:self.sonicPlayerView];
        
        self.resonicImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ResonicWhite.png"]];
        [self.resonicImageView setAlpha:0.85];
        [self.resonicImageView setFrame:[self resonicImageViewFrame]];
        [self.resonicImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.resonicImageView];
        [self.resonicImageView setHidden:YES];
    }
    return self;
}

- (void)setSonic:(Sonic *)sonic
{
    if(_sonic != sonic){
        _sonic = sonic;
        [self configureViews];
    }
}

- (void) configureViews
{
    NSString* urlString = self.sonic.isResonic ? self.sonic.originalSonic.sonicUrlString : self.sonic.sonicUrlString;
    [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:urlString]];
    if([self.sonic isResonic])
    {
        [self.resonicImageView setHidden:NO];
    }
    else
    {
        [self.resonicImageView setHidden:YES];
    }
}


@end
