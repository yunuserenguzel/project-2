//
//  SonicCollectionView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/5/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"
#import "SonicPlayerView.h"

@interface SonicCollectionViewCell : UICollectionViewCell

@property (nonatomic) Sonic* sonic;
@property SonicPlayerView* sonicPlayerView;

@property UIImageView* resonicImageView;

@end
