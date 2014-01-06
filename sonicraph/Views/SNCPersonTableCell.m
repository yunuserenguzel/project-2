//
//  SNCPersonTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCPersonTableCell.h"
#import "SNCAPIManager.h"
@implementation SNCPersonTableCell

- (CGRect) usernameLabelFrame
{
    return CGRectMake(60.0, 0.0, 320.0 - 60.0, 44.0);
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
}

- (void) setUser:(User *)user
{
    
    [self.imageView setImage:[UIImage imageNamed:@"PhotoBaseWithLogo.png"]];
    [self.usernameLabel setText:@"yeguzel"];
    [SNCAPIManager getImage:[NSURL URLWithString:@"http://i.stack.imgur.com/CfKcT.jpg?s=128&g=1"] withCompletionBlock:^(UIImage* image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
