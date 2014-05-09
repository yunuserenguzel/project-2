//
//  ProfileHeaderView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/3/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FadingImageView.h"
#define ProfileHeaderViewHeight 240.0

@interface ProfileHeaderView : UIView <UIGestureRecognizerDelegate>

@property FadingImageView* userProfileImageView;
@property UILabel* fullnameLabel;
@property UILabel* usernamelabel;
@property UILabel* locationLabel;
@property UITextView* websiteTextView;
@property UIImageView* locationImageView;
@property UIImageView* websiteImageView;

@property UILabel* numberOfSonicsLabel;
@property UILabel* numberOfFollowersLabel;
@property UILabel* numberOfFollowingsLabel;

@property UILabel* sonicsLabel;
@property UILabel* followersLabel;
@property UILabel* followingsLabel;

@property UIView* buttonHolderView;
@property UIButton* gridViewButton;
@property UIButton* listViewButton;
@property UIButton* likedSonicsButton;
@property UIButton* followButton;

@end
