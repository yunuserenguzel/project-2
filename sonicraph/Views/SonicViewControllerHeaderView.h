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

#define HeaderViewMaxHeight 450.0
#define HeaderViewMinHeight 44.0

@interface SonicViewControllerHeaderView : UIView

@property SonicPlayerView* sonicPlayerView;
@property UILabel* usernameLabel;
@property UILabel* fullnameLabel;
@property UIImageView* profileImageView;
@property UILabel* createdAtLabel;

//@property SegmentedBar* segmentedBar;
//@property SegmentedBarItem* likesBarItem;
//@property SegmentedBarItem* commentsBarItem;
//@property SegmentedBarItem* resonicsBarItem;
@property UISegmentedControl* segmentedBar;

@property UIView* tapToTopView;

@property Sonic* sonic;

- (void) reorganizeForRatio:(CGFloat)ratio;
- (void) addTargetForTapToTop:(id)target action:(SEL)selector;
@end