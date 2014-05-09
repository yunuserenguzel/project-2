//
//  SonicCommentCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/2/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicComment.h"
#import "TypeDefs.h"
#import "FadingImageView.h"

@interface SonicCommentCell : UITableViewCell <UIActionSheetDelegate>

@property (nonatomic) SonicComment* sonicComment;

@property UILabel* fullnameLabel;
@property UILabel* commentTextLabel;
@property UILabel* createdAtLabel;
@property UIButton* deleteButton;
@property FadingImageView* userProfileImageView;

@property (weak) id<OpenProfileProtocol> delegate;

+ (CGFloat) cellHeightForText:(NSString*)text;

+ (CGFloat) labelHeightForText:(NSString*)text;

@end
