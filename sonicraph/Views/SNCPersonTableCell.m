//
//  SNCPersonTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCPersonTableCell.h"
#import "SNCAPIManager.h"
#import "Configurations.h"
@implementation SNCPersonTableCell

- (CGRect) profileImageViewFrame
{
    return CGRectMake(10.0, PersonTableCellHeight * 0.5 - 22.0, 44.0, 44.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(60.0, PersonTableCellHeight * 0.5 - 22.0, 320.0 - 60.0, 44.0);
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
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setTextColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:self.usernameLabel];
    self.profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageViewFrame]];
    [self.profileImageView setFrame:[self profileImageViewFrame]];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self.profileImageView.layer setCornerRadius:5.0];
    [self.profileImageView setImage:[UIImage imageNamed:@"PhotoBaseWithLogo.png"]];
    [self.contentView addSubview:self.profileImageView];
}

- (void) setUser:(User *)user
{
    _user = user;
    if(user){
        [self.usernameLabel setText:user.username];
        [SNCAPIManager getImage:[NSURL URLWithString:user.profileImageUrl] withCompletionBlock:^(UIImage* image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image){
                    [self.profileImageView setImage:image];
                }
            });
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation SNCPersonFollowableTableCell

- (CGRect) followContentFrame
{
    return CGRectMake(320.0-88.0, 0.0, 88.0, PersonTableCellHeight);
}

- (CGRect) followButtonFrame
{
    CGRect frame = [self followContentFrame];
    frame.origin = CGPointZero;
    return frame;
}
- (void) initViews{
    [super initViews];
    self.followContent = [[UIView alloc] initWithFrame:[self followContentFrame]];
    [self.followContent setUserInteractionEnabled:YES];
    [self.contentView addSubview:self.followContent];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followButton setFrame:[self followButtonFrame]];
    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followContent addSubview:self.followButton];

    self.unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unfollowButton setFrame:[self followButtonFrame]];
    [self.unfollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    [self.unfollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followContent addSubview:self.unfollowButton];
    
    [self.followButton setHidden:YES];
    [self.unfollowButton setHidden:YES];
    
    [self.followButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.unfollowButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUser:(User *)user
{
    [super setUser:user];
    if(user.isBeingFollowed){
        [self.unfollowButton setHidden:NO];
        [self.followButton setHidden:YES];
    }else {
        [self.unfollowButton setHidden:YES];
        [self.followButton setHidden:NO];
    }
}

- (void) buttonTapped:(UIButton*)button
{
    if(button == self.followButton){
        [self.delegate followUser:self.user];
    } else if(self.unfollowButton){
        [self.delegate unfollowUser:self.user];
    }
}

@end








