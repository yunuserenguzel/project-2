//
//  SNCHomeTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"
#import "TypeDefs.h"

#define HomeTableCellIdentifier @"HomeTableCellIdentifier"
@class SNCHomeTableCell;

typedef enum SNCHomeTableCellActionType {
    SNCHomeTableCellActionTypeComment,
    SNCHomeTableCellActionTypeLike,
    SNCHomeTableCellActionTypeOpenLikes,
    SNCHomeTableCellActionTypeOpenComments,
    SNCHomeTableCellActionTypeResonic,
    SNCHomeTableCellActionTypeOpenResonics
}
SNCHomeTableCellActionType;

@protocol SNCHomeTableCellProtocol

- (void) sonic:(Sonic*)sonic actionFired:(SNCHomeTableCellActionType) actionType;

@end

@interface SNCHomeTableCell : UITableViewCell

@property id<SNCHomeTableCellProtocol,OpenProfileProtocol> delegate;

@property (nonatomic) Sonic* sonic;


@property UIImageView* userImageView;
@property UIImageView* userImageMaskView;
@property UILabel* usernameLabel;
@property UILabel* fullnameLabel;
@property UILabel* timestampLabel;
@property UILabel* resonicedByUsernameLabel;
@property UIImageView* resonicImageView;

@property UIButton* likeButton;
@property UIButton* commentButton;
@property UIButton* resonicButton;
@property UIButton* moreButton;

@property UILabel* likesCountLabel;
@property UILabel* commentsCountLabel;
@property UILabel* resonicsCountLabel;

- (void) cellWonCenterOfTableView;
- (void) cellLostCenterOfTableView;


@end
