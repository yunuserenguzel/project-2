//
//  SNCHomeTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeTableCell.h"
#import "SonicData.h"
#import "SonicPlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "SNCAPIManager.h"

#import "TypeDefs.h"

#define ButtonsTop 385.0
#define LabelsTop 365.0
@interface SNCHomeTableCell ()

@property SonicPlayerView* sonicPlayerView;

@end

@implementation SNCHomeTableCell

- (CGRect) userImageViewFrame
{
    return  CGRectMake(10.0, 0.0, 44.0, 44.0);
}

- (CGRect) userImageMaskViewFrame
{
    return [self userImageViewFrame];
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

- (CGRect) timestampLabelFrame
{
    return CGRectMake(260.0, 0.0, 60.0, 22.0);
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 44.0, 320.0, 320.0);
}

- (CGRect) likeButtonFrame
{
    return CGRectMake(10.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) commentButtonFrame
{
    return CGRectMake(90.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) resonicButtonFrame
{
    return CGRectMake(170.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) shareButtonFrame
{
    return CGRectMake(250.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) likesLabelFrame
{
    return CGRectMake(10.0, LabelsTop, 88.0, 22.0);
}

- (CGRect) commentsLabelFrame
{
    return CGRectMake(90.0, LabelsTop, 88.0, 22.0);
}

- (CGRect) resonicsLabelFrame
{
    return CGRectMake(170.0, LabelsTop, 88.0, 22.0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationLikedSonic:) name:NotificationLikeSonic object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationDislikedSonic:) name:NotificationDislikeSonic object:nil];
        
    }
    return self;
}

- (void) initViews
{
//    [self.layer setBorderColor:[UIColor redColor].CGColor];
//    [self.layer setBorderWidth:1.0f];
    
    self.userImageView = [[UIImageView alloc] initWithFrame:[self userImageViewFrame]];
    [self addSubview:self.userImageView];
    
    self.userImageMaskView = [[UIImageView alloc] initWithFrame:[self userImageMaskViewFrame]];
    [self addSubview:self.userImageMaskView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self addSubview:self.usernameLabel];
    
    self.timestampLabel = [[UILabel alloc] initWithFrame:[self timestampLabelFrame]];
    [self addSubview:self.timestampLabel];
    
    self.sonicPlayerView = [[SonicPlayerView alloc] init];
    [self.sonicPlayerView setFrame:[self sonicPlayerViewFrame]];
    [self addSubview:self.sonicPlayerView];
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self addSubview:self.usernameLabel];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.likeButton setFrame:[self likeButtonFrame]];
    [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeSonic) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.likeButton];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentButton setFrame:[self commentButtonFrame]];
    [self.commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentSonic) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.commentButton];
    
    self.resonicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.resonicButton setFrame:[self resonicButtonFrame]];
    [self.resonicButton setTitle:@"resonic" forState:UIControlStateNormal];
    [self.resonicButton addTarget:self action:@selector(resonic) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.resonicButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.shareButton setFrame:[self shareButtonFrame]];
    [self.shareButton setTitle:@"share" forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.shareButton];
    

    self.likesCountLabel = [[UILabel alloc] initWithFrame:[self likesLabelFrame]];
//    [self.likesCountLabel.layer setBorderColor:[UIColor redColor].CGColor];
//    [self.likesCountLabel.layer setBorderWidth:1.0f];
    [self.likesCountLabel setText:@"Likes 99"];
    [self.likesCountLabel setFont:[self.likesCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.likesCountLabel];
    
    self.commentsCountLabel = [[UILabel alloc] initWithFrame:[self commentsLabelFrame]];
    [self.commentsCountLabel setText:@"Comments 15"];
    [self.commentsCountLabel setFont:[self.commentsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.commentsCountLabel];
    
    self.resonicsCountLabel = [[UILabel alloc] initWithFrame:[self resonicsLabelFrame]];
    [self.resonicsCountLabel setText:@"Resonics 45"];
    [self.resonicsCountLabel setFont:[self.resonicsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.resonicsCountLabel];
    
}

- (void) share
{
    
}

- (void) resonic
{
    
}

- (void) commentSonic
{
    
}

- (void)likeSonic
{
    [self.likeButton setHighlighted:YES];
    if ([self.likeButton isSelected]){
        [self.likeButton setSelected:NO];
        [SNCAPIManager dislikeSonic:self.sonic withCompletionBlock:nil andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
    else {
        [self.likeButton setSelected:YES];
        [SNCAPIManager likeSonic:self.sonic withCompletionBlock:nil andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:NO];
        }];
    }
    
}

- (void)receivedNotificationLikedSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonic.sonicId isEqualToString:sonic.sonicId]){
        [self.likeButton setSelected:YES];
    }
}
- (void)receivedNotificationDislikedSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonic.sonicId isEqualToString:sonic.sonicId]){
        [self.likeButton setSelected:NO];
    }
}

- (void)setSonic:(Sonic *)sonic
{
    if(_sonic != sonic){
        _sonic = sonic;
        [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:sonic.sonicUrl]];
        [self.usernameLabel setText:[self.sonic.owner fullName]];
        [self.timestampLabel setText:[[self.sonic creationDate] description]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellWonCenterOfTableView
{
    [self.sonicPlayerView play];
}

- (void) cellLostCenterOfTableView
{
    [self.sonicPlayerView pause];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
