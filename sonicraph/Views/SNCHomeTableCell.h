//
//  SNCHomeTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

#define HomeTableCellIdentifier @"HomeTableCellIdentifier"

@interface SNCHomeTableCell : UITableViewCell

@property (nonatomic) Sonic* sonic;

@property UIImageView* userImageView;
@property UIImageView* userImageMaskView;
@property UILabel* usernameLabel;
@property UILabel* timestampLabel;

@property UIButton* likeButton;
@property UIButton* commentButton;
@property UIButton* resonicButton;
@property UIButton* shareButton;


@property UILabel* likesCountLabel;
@property UILabel* commentsCountLabel;
@property UILabel* resonicsCountLabel;


- (void) cellWonCenterOfTableView;
- (void) cellLostCenterOfTableView;


@end
