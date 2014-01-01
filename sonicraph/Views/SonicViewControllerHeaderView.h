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

#define LikesTabButtonTag 5111
#define CommentsTabButtonTag 5112
#define ResonicsTabButtonTag 5113


#define HeaderViewMaxHeight 431.0
#define HeaderViewMinHeight 110.0

@interface SonicViewControllerHeaderView : UIView

@property SonicPlayerView* sonicPlayerView;
@property UILabel* usernameLabel;
@property UIImageView* profileImageView;

@property UIView* tabsView;
@property UIButton* likesTabButton;
@property UIButton* commentsTabButton;
@property UIButton* resonicsTabButton;

@property Sonic* sonic;

- (void) setButtonTargets:(id)target selector:(SEL) selector;

- (void) reorganizeForRatio:(CGFloat)ratio;
@end