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
    return CGRectMake(15.0, 20.0, 110.0, 110.0);
}

- (CGRect) fullnameLabelFrame
{
    return CGRectMake(140.0, 18.0, 160.0, 22.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(140.0, 35.0, 160.0, 20.0);
}

- (CGRect) locationLabelFrame
{
    return CGRectMake(156.0, 60.0, 160.0, 20.0);
}
- (CGRect) locationImageViewFrame
{
    return CGRectMake(140.0, 64.0, 12.0, 12.0);
}
- (CGRect) websiteLabelFrame
{
    return CGRectMake(152.0, 78.0, 160.0, 20.0);
}
- (CGRect) websiteImageViewFrame
{
    return CGRectMake(140.0, 80.0, 12.0, 12.0);
}
- (CGRect) followButtonFrame
{
    return CGRectMake(140.0, 100.0, 150.0, 30.0);
}

- (CGRect) numberOfSonicsLabelFrame
{
    return CGRectMake(10.0, 160.0, 96.6, 24.0);
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
    return CGRectMake(10.0, 140.0, 96.6, 22.0);
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
    frame.origin.x = 10;
    frame.size.width = 96.6;
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
        [self setBackgroundColor:[UIColor whiteColor]];
        [self initProfileImageAndUserInfoLabels];
        [self initCountableLabels];
        [self initTabButtons];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton setBackgroundImageWithColor:MainThemeColor forState:UIControlStateNormal];
        [self.followButton setBackgroundImageWithColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.followButton setFrame:[self followButtonFrame]];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following" forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followButton setTitleColor:MainThemeColor forState:UIControlStateSelected];
        [self.followButton.layer setCornerRadius:5.0];
        self.followButton.layer.borderColor = MainThemeColor.CGColor;
        self.followButton.layer.borderWidth = 1.0;
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.followButton setClipsToBounds:YES];
        [self addSubview:self.followButton];

    }
    return self;
}

- (void) initProfileImageAndUserInfoLabels
{
    self.userProfileImageView = [[UIImageView alloc] initWithImage:UserPlaceholderImage];
    [self.userProfileImageView setFrame:[self userProfileImageViewFrame]];
    [self.userProfileImageView.layer setCornerRadius:[self userProfileImageViewFrame].size.width * 0.5];
    [self.userProfileImageView setClipsToBounds:YES];
    [self.userProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:self.userProfileImageView];
    
    UIView* userProfileImageBorder = [[UIView alloc] init];
    CGRect frame = [self userProfileImageViewFrame];
    frame.size.height += 2;
    frame.size.width += 2;
    frame.origin.x -=1;
    frame.origin.y -=1;
    [userProfileImageBorder setFrame:frame];
    [userProfileImageBorder.layer setCornerRadius:frame.size.height * 0.5];
    [userProfileImageBorder.layer setBorderColor:rgb(240, 240, 240).CGColor];
    [userProfileImageBorder.layer setBorderWidth:3.0];
    [self addSubview:userProfileImageBorder];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    self.fullnameLabel.font = [UIFont systemFontOfSize:16.0];
    self.fullnameLabel.textColor = FullnameTextColor;
    [self addSubview:self.fullnameLabel];
    
    self.usernamelabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    self.usernamelabel.font = [UIFont systemFontOfSize:14.0];
    self.usernamelabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.usernamelabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:[self locationLabelFrame]];
    self.locationLabel.font = [UIFont systemFontOfSize:14.0];
    self.locationLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.locationLabel];
    
    self.locationImageView = [[UIImageView alloc] initWithFrame:[self locationImageViewFrame]];
    [self addSubview:self.locationImageView];
    self.locationImageView.image = [UIImage imageNamed:@"location.png"];
    self.locationImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.websiteTextView = [[UITextView alloc] initWithFrame:[self websiteLabelFrame]];
    self.websiteTextView.editable = NO;
    [self.websiteTextView setTextAlignment:NSTextAlignmentLeft];
    [self.websiteTextView setTextContainerInset:UIEdgeInsetsZero];
    self.websiteTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.websiteTextView setContentInset:UIEdgeInsetsZero];
    self.websiteTextView.font = [UIFont systemFontOfSize:13.0];
    [self.websiteTextView setTintColor:[UIColor lightGrayColor]];
    self.websiteTextView.textColor = [UIColor lightGrayColor];
    [self.websiteTextView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.websiteTextView];
    
    self.websiteImageView = [[UIImageView alloc] initWithFrame:[self websiteImageViewFrame]];
    [self addSubview:self.websiteImageView];
    self.websiteImageView.image = [UIImage imageNamed:@"el.png"];
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
        label.font = [UIFont systemFontOfSize:22.0];
        label.textColor = MainThemeColor;
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
    [self.gridViewButton setImage:[UIImage imageNamed:@"gridview.png"] forState:UIControlStateNormal];
    [self.gridViewButton setImage:[UIImage imageNamed:@"gridviewactive.png"] forState:UIControlStateSelected];
    [self.gridViewButton setContentMode:UIViewContentModeCenter];
    [self.buttonHolderView addSubview:self.gridViewButton];
    
    self.listViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listViewButton setFrame:[self listViewButtonFrame]];
    [self.listViewButton setImage:[UIImage imageNamed:@"listview.png"] forState:UIControlStateNormal];
    [self.listViewButton setImage:[UIImage imageNamed:@"listviewactive.png"] forState:UIControlStateSelected];
    [self.listViewButton setContentMode:UIViewContentModeCenter];
    [self.buttonHolderView addSubview:self.listViewButton];
    
    self.likedSonicsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likedSonicsButton setFrame:[self likedSonicsButtonFrame]];
    [self.likedSonicsButton setImage:[UIImage imageNamed:@"likedsonics.png"] forState:UIControlStateNormal];
    [self.likedSonicsButton setImage:[UIImage imageNamed:@"likedsonicsactive.png"] forState:UIControlStateSelected];
    [self.likedSonicsButton setContentMode:UIViewContentModeCenter];
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
