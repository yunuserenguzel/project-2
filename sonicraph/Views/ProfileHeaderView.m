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
#import "Configurations.h"
#import "UIButton+StateProperties.h"

@implementation ProfileHeaderView
- (CGRect) userProfileImageViewFrame
{
    return CGRectMake(10.0, 10.0, 120.0, 120.0);
}

- (CGRect) fullnameLabelFrame
{
    return CGRectMake(140.0, 10.0, 160.0, 22.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(140.0, 28.0, 160.0, 20.0);
}

- (CGRect) locationLabelFrame
{
    return CGRectMake(154.0, 54.0, 160.0, 20.0);
}
- (CGRect) locationImageViewFrame
{
    return CGRectMake(140.0, 58.0, 12.0, 12.0);
}
- (CGRect) websiteLabelFrame
{
    return CGRectMake(154.0, 70.0, 160.0, 20.0);
}
- (CGRect) websiteImageViewFrame
{
    return CGRectMake(140.0, 74.0, 12.0, 12.0);
}
- (CGRect) followButtonFrame
{
    return CGRectMake(140.0, 100.0, 150.0, 30.0);
}

- (CGRect) numberOfSonicsLabelFrame
{
    return CGRectMake(10.0, 145.0, 96.6, 22.0);
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
    return CGRectMake(10.0, 165.0, 96.6, 22.0);
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
    return CGRectMake(0.0, 195.0, 320.0, 44.0);
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

- (CGRect) likedSonicsButtonFrame
{
    CGRect frame = [self listViewButtonFrame];
    frame.origin.x += frame.size.width;
    return frame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setBackgroundColor:rgb(245,245,245)];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self initProfileImageAndUserInfoLabels];
        [self initCountableLabels];
        [self initTabButtons];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton setBackgroundImageWithColor:PinkColor forState:UIControlStateNormal];
        [self.followButton setBackgroundImageWithColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.followButton setFrame:[self followButtonFrame]];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following" forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followButton setTitleColor:PinkColor forState:UIControlStateSelected];
        [self.followButton.layer setCornerRadius:5.0];
        self.followButton.layer.borderColor = PinkColor.CGColor;
        self.followButton.layer.borderWidth = 1.0;
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.followButton setClipsToBounds:YES];
        [self addSubview:self.followButton];

    }
    return self;
}

- (void) initProfileImageAndUserInfoLabels
{
    self.userProfileImageView = [[UIImageView alloc] initWithImage:SonicPlaceholderImage];
    [self.userProfileImageView setFrame:[self userProfileImageViewFrame]];
    [self.userProfileImageView.layer setCornerRadius:10.0];
    [self.userProfileImageView setClipsToBounds:YES];
    [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:self.userProfileImageView];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    self.fullnameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    self.fullnameLabel.textColor = FullnameTextColor;
    [self addSubview:self.fullnameLabel];
    
    self.usernamelabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    self.usernamelabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.usernamelabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.usernamelabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:[self locationLabelFrame]];
    self.locationLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.locationLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.locationLabel];
    
    self.locationImageView = [[UIImageView alloc] initWithFrame:[self locationImageViewFrame]];
    [self addSubview:self.locationImageView];
    self.locationImageView.image = [UIImage imageNamed:@"Location.png"];
    self.locationImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.websiteLabel = [[UILabel alloc] initWithFrame:[self websiteLabelFrame]];
    self.websiteLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.websiteLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.websiteLabel];
    
    self.websiteImageView = [[UIImageView alloc] initWithFrame:[self websiteImageViewFrame]];
    [self addSubview:self.websiteImageView];
    self.websiteImageView.image = [UIImage imageNamed:@"WebIcon.png"];
    self.websiteImageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecoznizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (void) initCountableLabels
{
    self.numberOfSonicsLabel = [[UILabel alloc] initWithFrame:[self numberOfSonicsLabelFrame]];
    [self.numberOfSonicsLabel setText:@" "];
    self.numberOfFollowersLabel = [[UILabel alloc] initWithFrame:[self numberOfFollowersLabelFrame]];
    [self.numberOfFollowersLabel setText:@" "];
    self.numberOfFollowingsLabel = [[UILabel alloc] initWithFrame:[self numberOfFollowingsLabelFrame]];
    [self.numberOfFollowingsLabel setText:@" "];
    [@[self.numberOfSonicsLabel,self.numberOfFollowingsLabel,self.numberOfFollowersLabel] enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
        [self addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = PinkColor;
        [label setUserInteractionEnabled:YES];
    }];
    
    self.sonicsLabel = [[UILabel alloc] initWithFrame:[self sonicsLabelFrame]];
    [self.sonicsLabel setText:@"Sonics"];
    self.followersLabel = [[UILabel alloc] initWithFrame:[self followersLabelFrame]];
    [self.followersLabel setText:@"Followers"];
    self.followingsLabel = [[UILabel alloc] initWithFrame:[self followingsLabelFrame]];
    [self.followingsLabel setText:@"Following"];
    [@[self.sonicsLabel,self.followersLabel,self.followingsLabel] enumerateObjectsUsingBlock:^(UILabel* label, NSUInteger idx, BOOL *stop) {
        [self addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:16.0];
        [label setTextColor:[UIColor grayColor]];
        [label setUserInteractionEnabled:YES];
    }];
}

- (void) initTabButtons
{
    self.buttonHolderView = [[UIView alloc] initWithFrame:[self buttonHolderViewFrame]];
    [self.buttonHolderView setBackgroundColor:rgb(240, 240, 240)];
    [self addSubview:self.buttonHolderView];
    
    self.gridViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gridViewButton setFrame:[self gridViewButtonFrame]];
    [self.gridViewButton setImage:[UIImage imageNamed:@"ViewGridLightPink.png"] forState:UIControlStateNormal];
    [self.gridViewButton setImage:[UIImage imageNamed:@"ViewGridPink.png"] forState:UIControlStateSelected];
    [self.buttonHolderView addSubview:self.gridViewButton];
    
    self.listViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listViewButton setFrame:[self listViewButtonFrame]];
    [self.listViewButton setImage:[UIImage imageNamed:@"ViewListLightPink.png"] forState:UIControlStateNormal];
    [self.listViewButton setImage:[UIImage imageNamed:@"ViewListPink.png"] forState:UIControlStateSelected];
    [self.buttonHolderView addSubview:self.listViewButton];
    
    self.likedSonicsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likedSonicsButton setFrame:[self likedSonicsButtonFrame]];
    [self.likedSonicsButton setImage:[UIImage imageNamed:@"LikeTabLightPink.png"] forState:UIControlStateNormal];
    [self.likedSonicsButton setImage:[UIImage imageNamed:@"LikeTabPink.png"] forState:UIControlStateSelected];
    [self.buttonHolderView addSubview:self.likedSonicsButton];
    [self.likedSonicsButton setHidden:YES];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, rgb(225,225,225).CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 0,[self buttonHolderViewFrame].origin.y); //start at this point
    CGContextAddLineToPoint(context, [self buttonHolderViewFrame].size.width, [self buttonHolderViewFrame].origin.y); //draw to this point
    CGContextStrokePath(context);
}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView* view = [super hitTest:point withEvent:event];
//    if(view == self){
//        return nil;
//    }
//    else {
//        return view;
//    }
//}

@end
