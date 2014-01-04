//
//  SonicCommentCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/2/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicComment.h"

@interface SonicCommentCell : UITableViewCell

@property (nonatomic) SonicComment* sonicComment;

@property UILabel* usernameLabel;
@property UILabel* commentTextLabel;
@property UIImageView* userProfileImageView;
@end
