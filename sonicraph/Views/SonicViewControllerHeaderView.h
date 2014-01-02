//
//  SonicViewControllerHeaderView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/1/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicPlayerView.h"
#import "TypeDefs.h"
#import "SegmentedBar.h"

#define LikesTabButtonTag 5111
#define CommentsTabButtonTag 5112
#define ResonicsTabButtonTag 5113

#define HeaderViewMaxHeight 448.0
#define HeaderViewMinHeight 127.0

@interface SonicViewControllerHeaderView : UIView

@property SonicPlayerView* sonicPlayerView;
@property UILabel* usernameLabel;
@property UIImageView* profileImageView;

@property SegmentedBar* segmentedBar;
@property UIButton* likesTabButton;
@property UIButton* commentsTabButton;
@property UIButton* resonicsTabButton;

@property UIView* tapToTopView;

@property Sonic* sonic;

- (void) reorganizeForRatio:(CGFloat)ratio;
- (void) addTargetForTapToTop:(id)target action:(SEL)selector;
@end