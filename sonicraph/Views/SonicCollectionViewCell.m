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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self imageViewFrame]];
        [self.sonicPlayerView setUserInteractionEnabled:NO];
        [self.contentView addSubview:self.sonicPlayerView];
    }
    return self;
}

- (void)setSonic:(Sonic *)sonic
{
    if(_sonic != sonic){
        _sonic = sonic;
        [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    }
}


@end
