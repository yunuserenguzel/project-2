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


@interface SNCHomeTableCell ()

@property SonicPlayerView* sonicPlayerView;

@property UILabel* usernameLabel;

@end

@implementation SNCHomeTableCell

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 44.0, 320.0, 320.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

- (CGRect) likeButtonFrame;
{
    return CGRectMake(10.0, 364.0, 44.0, 44.0);
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
    [self.layer setBorderColor:[UIColor redColor].CGColor];
    [self.layer setBorderWidth:1.0f];
 
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
