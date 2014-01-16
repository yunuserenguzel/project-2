//
//  SonicCommentCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/2/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Configurations.h"


@implementation SonicCommentCell

- (CGRect) usernameLabelFrame
{
    return CGRectMake(66.0, 0.0, self.frame.size.width - 66.0, 22.0);
}

- (CGRect) textLabelFrame
{
    return CGRectMake(66.0, 18.0, self.frame.size.width - 66.0, 40.0);
}

- (CGRect) userProfileImageViewFrame
{
    return CGRectMake(10.0, 10.0, 44.0, 44.0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.userProfileImageView = [[UIImageView alloc] initWithFrame:[self userProfileImageViewFrame]];
    [self.contentView addSubview:self.userProfileImageView];
    [self.userProfileImageView setClipsToBounds:YES];
    [self.userProfileImageView setUserInteractionEnabled:YES];
    [self.userProfileImageView.layer setCornerRadius:6.0];
    [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setUserInteractionEnabled:YES];
    [self.contentView addSubview:self.usernameLabel];
//    self.usernameLabel.font = [self.usernameLabel.font fontWithSize:12.0];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.usernameLabel.textColor = NavigationBarBlueColor;
    self.usernameLabel.numberOfLines = 1;
    self.commentTextLabel = [[UILabel alloc] initWithFrame:[self textLabelFrame]];
    [self.contentView addSubview:self.commentTextLabel];
    [self.commentTextLabel setTextColor:[UIColor darkGrayColor]];
    self.commentTextLabel.font = [self.commentTextLabel.font fontWithSize:14.0];
    self.commentTextLabel.numberOfLines = 0;
    
    
    UIGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.usernameLabel addGestureRecognizer:tapGesture];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.userProfileImageView addGestureRecognizer:tapGesture];
}

- (void) tapGesture
{
    [self.delegate openProfileForUser:self.sonicComment.user];
}

- (void)setSonicComment:(SonicComment *)sonicComment
{
    _sonicComment = sonicComment;
    [self configureViews];
}

- (void) configureViews
{
    [self.userProfileImageView setImage:[UIImage imageNamed:@"2013-11-07 09.52.53.jpg"]];
    [self.usernameLabel setText:self.sonicComment.user.username];
    [self.commentTextLabel setText:self.sonicComment.text];
//    [self.commentTextLabel setText:@"asdasdasdas asdasdasd aasdasdasdas a asdasdasd ereren asldkasld jkjhewr dkfdsf rweuirw "];
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView* subview, NSUInteger idx, BOOL *stop) {
        NSLog(@"subview: %@",subview);
//        [subview.subviews enumerateObjectsUsingBlock:^(UIView* subsubview, NSUInteger idx, BOOL *stop) {
//            NSLog(@"subsubview: %@",subsubview);
//        }];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
