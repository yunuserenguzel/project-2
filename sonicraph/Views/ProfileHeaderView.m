//
//  ProfileHeaderView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/3/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "TypeDefs.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileHeaderView
- (CGRect) userProfileImageViewFrame
{
    return CGRectMake(10.0, 10.0, 64.0, 64.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(84.0, 10.0, 320.0 - 64.0, 22.0);
}

- (CGRect) userDescriptionLabelFrame
{
    CGRect frame = [self usernameLabelFrame];
    frame.origin.y += frame.size.height;
    frame.size.height = 22.0;
    return frame;
}


- (CGRect) numberOfSonicsLabelFrame
{
    return CGRectMake(30.0, 86.0, 96.6, 22.0);
}

- (CGRect) numberOfFollowersLabelFrame
{
    CGRect frame = [self numberOfSonicsLabelFrame];
    frame.origin.x += frame.size.width;
    return  frame;
}

- (CGRect) numberOfFollowingsLabelFrame
{
    CGRect frame = [self numberOfFollowersLabelFrame];
    frame.origin.x += frame.size.width;
    return frame;
}

- (CGRect) sonicsLabelFrame
{
    return CGRectMake(30.0, 102.0, 96.6, 22.0);
}


- (CGRect) followersLabelFrame
{
    CGRect frame = [self sonicsLabelFrame];
    frame.origin.x += frame.size.width;
    return frame;
}

- (CGRect) followingsLabelFrame
{
    CGRect frame = [self followersLabelFrame];
    frame.origin.x += frame.size.width;
    return frame;
}

- (CGRect) buttonHolderViewFrame
{
    return CGRectMake(0.0, 136.0, 320.0, 44.0);
}

- (CGRect) gridViewButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size.width = 80.0;
    frame.size.height = [self buttonHolderViewFrame].size.height;
    return frame;
}

- (CGRect) listViewButtonFrame
{
    CGRect frame = [self gridViewButtonFrame];
    frame.origin.x += frame.size.width;
    return frame;
}

- (CGRect) followButtonFrame
{
    CGRect frame = [self listViewButtonFrame];
    frame.origin.x += frame.size.width;
    frame.size.width = 160.0;
    return frame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:rgb(245,245,245)];
        self.userProfileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2013-11-07 09.52.53.jpg"]];
        [self.userProfileImageView setFrame:[self userProfileImageViewFrame]];
        [self.userProfileImageView.layer setCornerRadius:5.0];
        [self.userProfileImageView setClipsToBounds:YES];
        [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.userProfileImageView];
        
        self.usernamelabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
        [self.usernamelabel setText:@"yeguzel"];
        self.usernamelabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:self.usernamelabel];
        
        self.userDescriptionLabel = [[UILabel alloc] initWithFrame:[self userDescriptionLabelFrame]];
        [self.userDescriptionLabel setText:@"computer scientist"];
        self.userDescriptionLabel.font = [self.userDescriptionLabel.font fontWithSize:14.0];
        [self.userDescriptionLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.userDescriptionLabel];
        
        self.numberOfSonicsLabel = [[UILabel alloc] initWithFrame:[self numberOfSonicsLabelFrame]];
        [self.numberOfSonicsLabel setText:@"345"];
        self.numberOfFollowersLabel = [[UILabel alloc] initWithFrame:[self numberOfFollowersLabelFrame]];
        [self.numberOfFollowersLabel setText:@"112"];
        self.numberOfFollowingsLabel = [[UILabel alloc] initWithFrame:[self numberOfFollowingsLabelFrame]];
        [self.numberOfFollowingsLabel setText:@"13"];
        [@[self.numberOfSonicsLabel,self.numberOfFollowingsLabel,self.numberOfFollowersLabel] enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
            [self addSubview:label];
            label.font = [UIFont boldSystemFontOfSize:14.0];
            [label setUserInteractionEnabled:YES];
//            if(idx < 2){
//                UIImageView* seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SegmentedButtonBarSeperator.png"]];
//                [seperator setContentMode:UIViewContentModeCenter];
//                CGRect frame = label.frame;
//                frame.origin.x += frame.size.width - 1.0;
//                frame.size.width = 1.0;
//                [seperator setFrame:frame];
//                [self addSubview:seperator];
//            }
        }];
        
        self.sonicsLabel = [[UILabel alloc] initWithFrame:[self sonicsLabelFrame]];
        [self.sonicsLabel setText:@"Sonics"];
        self.followersLabel = [[UILabel alloc] initWithFrame:[self followersLabelFrame]];
        [self.followersLabel setText:@"Followers"];
        self.followingsLabel = [[UILabel alloc] initWithFrame:[self followingsLabelFrame]];
        [self.followingsLabel setText:@"Following"];
        [@[self.sonicsLabel,self.followersLabel,self.followingsLabel] enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
            [self addSubview:label];
            label.font = [label.font fontWithSize:14.0];
            [label setTextColor:[UIColor darkGrayColor]];
            [label setUserInteractionEnabled:YES];
        }];
        
        self.buttonHolderView = [[UIView alloc] initWithFrame:[self buttonHolderViewFrame]];
        [self addSubview:self.buttonHolderView];
        
        self.gridViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.gridViewButton setFrame:[self gridViewButtonFrame]];
        [self.gridViewButton setImage:[UIImage imageNamed:@"ViewThumbnailDarkGrey.png"] forState:UIControlStateNormal];
        [self.buttonHolderView addSubview:self.gridViewButton];
        
        self.listViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.listViewButton setFrame:[self listViewButtonFrame]];
        [self.listViewButton setImage:[UIImage imageNamed:@"ViewListDarkGrey.png"] forState:UIControlStateNormal];
        [self.buttonHolderView addSubview:self.listViewButton];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton setFrame:[self followButtonFrame]];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.buttonHolderView addSubview:self.followButton];

        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, rgb(225,225,225).CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 0.5);
    
    CGContextMoveToPoint(context, 0,[self buttonHolderViewFrame].origin.y); //start at this point
    
    CGContextAddLineToPoint(context, [self buttonHolderViewFrame].size.width, [self buttonHolderViewFrame].origin.y); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view = [super hitTest:point withEvent:event];
    if(view == self){
        return nil;
    }
    else {
        return view;
    }
}

@end
