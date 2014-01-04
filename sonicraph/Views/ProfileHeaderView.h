//
//  ProfileHeaderView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/3/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UIView

@property UIImageView* userProfileImageView;
@property UILabel* usernamelabel;
@property UILabel* userDescriptionLabel;

@property UILabel* numberOfSonicsLabel;
@property UILabel* numberOfFollowersLabel;
@property UILabel* numberOfFollowingsLabel;

@property UILabel* sonicsLabel;
@property UILabel* followersLabel;
@property UILabel* followingsLabel;

@property UIView* buttonHolderView;
@property UIButton* gridViewButton;
@property UIButton* listViewButton;
@property UIButton* followButton;

@end
