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
#import "NSDate+NVTimeAgo.h"

#define CommentTextFont [UIFont systemFontOfSize:14.0]

@implementation SonicCommentCell

+ (CGFloat)cellHeightForText:(NSString *)text
{
    return [self labelHeightForText:text] + 38.0;
}

+ (CGFloat)labelHeightForText:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName: CommentTextFont};

    CGRect rect = [text boundingRectWithSize:CGSizeMake(320.0 - 76.0 , MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
//    NSLog(@"text: %@\n rect: %@",text,CGRectCreateDictionaryRepresentation(rect));
    return MAX(rect.size.height + 3,24.0);
}
- (CGRect) fullnameLabelFrame
{
    return CGRectMake(58.0, 4.0, self.frame.size.width - 132.0, 22.0);
}

- (CGRect) textLabelFrame
{
    return CGRectMake(58.0, 22.0, self.frame.size.width - 76.0, 40.0);
}

- (CGRect) createdAtLabelFrame
{
    return CGRectMake(self.frame.size.width - 74.0, 0.0, 66.0 , 22.0);
}

- (CGRect) userProfileImageViewFrame
{
    return CGRectMake(5.0, 5.0, 49.0, 49.0);
}

- (CGRect) deleteButtonFrame
{
    return CGRectMake(320 - 44.0, 44.0, 44.0, 16.0);
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
    [self.userProfileImageView.layer setCornerRadius:[self userProfileImageViewFrame].size.height * 0.5];
    [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    [self.fullnameLabel setUserInteractionEnabled:YES];
    [self.contentView addSubview:self.fullnameLabel];
//    self.usernameLabel.font = [self.usernameLabel.font fontWithSize:12.0];
    self.fullnameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.fullnameLabel.textColor = FullnameTextColor;
    self.fullnameLabel.numberOfLines = 1;
    
    self.createdAtLabel = [[UILabel alloc] initWithFrame:[self createdAtLabelFrame]];
    [self.contentView addSubview:self.createdAtLabel];
    self.createdAtLabel.font = [UIFont boldSystemFontOfSize:10.0];
    self.createdAtLabel.textColor = [UIColor lightGrayColor];
    [self.createdAtLabel setTextAlignment:NSTextAlignmentRight];
    
    self.commentTextLabel = [[UILabel alloc] initWithFrame:[self textLabelFrame]];
    [self.contentView addSubview:self.commentTextLabel];
    [self.commentTextLabel setTextColor:[UIColor grayColor]];
    self.commentTextLabel.font = CommentTextFont;
    self.commentTextLabel.numberOfLines = 0;
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setFrame:[self deleteButtonFrame]];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
    
    UIGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.fullnameLabel addGestureRecognizer:tapGesture];
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
    [self.userProfileImageView setImage:UserPlaceholderImage];
    [self.sonicComment.user getThumbnailProfileImageWithCompletionBlock:^(UIImage* image,User* user) {
       dispatch_async(dispatch_get_main_queue(), ^{
           if(image && self.sonicComment.user == user){
               [self.userProfileImageView setImage:image];
           }
       });
    }];
    [self.fullnameLabel setText:self.sonicComment.user.fullName];
    [self.commentTextLabel setText:self.sonicComment.text];
    [self.createdAtLabel setText:[self.sonicComment.createdAt formattedAsTimeAgo]];

    CGRect textLabelFrame = [self textLabelFrame];
    textLabelFrame.size.height = [SonicCommentCell labelHeightForText:self.commentTextLabel.text];
    self.commentTextLabel.frame = textLabelFrame;
    
    CGRect deleteButtonFrame = [self deleteButtonFrame];
    deleteButtonFrame.origin.y = textLabelFrame.origin.y + textLabelFrame.size.height;
    self.deleteButton.frame = deleteButtonFrame;
    
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
