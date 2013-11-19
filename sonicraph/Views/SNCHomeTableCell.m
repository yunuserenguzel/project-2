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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.sonicPlayerView = [[SonicPlayerView alloc] init];
        [self.sonicPlayerView setFrame:[self sonicPlayerViewFrame]];
        [self addSubview:self.sonicPlayerView];
        self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
        [self addSubview:self.usernameLabel];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
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


@end
