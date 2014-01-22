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
#import "AuthenticationManager.h"

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

- (CGRect) deleteButtonFrame
{
    return CGRectMake(260.0, 44.0, 60.0, 22.0);
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
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setFrame:[self deleteButtonFrame]];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [self.deleteButton.titleLabel.font fontWithSize:10.0];
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
    
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

- (void) deleteButtonTapped
{
    [[[UIActionSheet alloc]
      initWithTitle:@"Comment"
      delegate:self
      cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:@"Confirm Delete"
      otherButtonTitles: nil]
     showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [SNCAPIManager deleteComment:self.sonicComment withCompletionBlock:nil andErrorBlock:nil];
    }
}

- (void)setSonicComment:(SonicComment *)sonicComment
{
    _sonicComment = sonicComment;
    [self configureViews];
}

- (void) configureViews
{
    [self.userProfileImageView setImage:SonicPlaceholderImage];
    [self.sonicComment.user getThumbnailProfileImageWithCompletionBlock:^(id object) {
       dispatch_async(dispatch_get_main_queue(), ^{
           if(object){
               [self.userProfileImageView setImage:object];
           }
       });
    }];
    [self.usernameLabel setText:self.sonicComment.user.username];
    [self.commentTextLabel setText:self.sonicComment.text];

    NSString* authUserId = [[[AuthenticationManager sharedInstance] authenticatedUser] userId];
    if([self.sonicComment.sonic.owner.userId isEqualToString:authUserId] || [self.sonicComment.user.userId isEqualToString:authUserId]){
        [self.deleteButton setHidden:NO];
    } else {
        [self.deleteButton setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
