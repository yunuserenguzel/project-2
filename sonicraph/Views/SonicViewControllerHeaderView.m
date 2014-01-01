//
//  SonicViewControllerHeaderView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/1/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicViewControllerHeaderView.h"



@implementation SonicViewControllerHeaderView
{
    BOOL isInitCalled;
}

- (CGRect) profileImageMaxFrame
{
    return CGRectMake(10.0, 11.0, 44.0, 44.0);
}
- (CGRect) usernameLabelMaxFrame
{
    return CGRectMake(64.0, 11.0, 244.0, 44.0);
}
- (CGRect) sonicPlayerViewMaxFrame
{
    return CGRectMake(0.0, 66.0, 320.0, 320.0);
}
- (CGRect) tabsViewMaxFrame
{
    return CGRectMake(0.0, 386.0, 320.0, 44.0);
}

- (CGRect) profileImageMinFrame
{
    return CGRectMake(10.0, 332.0, 44.0, 44.0);
}
- (CGRect) usernameLabelMinFrame
{
    return CGRectMake(64.0, 332.0, 244.0, 44.0);
}
- (CGRect) sonicPlayerViewMinFrame
{
    return CGRectMake(255.0, 321.0, 66.0, 66.0);
}
- (CGRect) tabsViewMinFrame
{
    return CGRectMake(0.0, 387.0, 320.0, 44.0);
}

- (CGRect) likesButtonFrame
{
    return CGRectMake(0.0, 0.0, 320.0 / 3.0, 44.0);
}
- (CGRect) commentsButtonFrame
{
    return CGRectMake(320.0*1.0/3.0, 0.0, 320.0 / 3.0, 44.0);
}
- (CGRect) resonicsButtonFrame
{
    return CGRectMake(320.0*2.0/3.0, 0.0, 320.0 / 3.0, 44.0);
}

- (id)init
{
    if(self = [super init]){
        [self initViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    if(isInitCalled){
        return;
    } else {
        isInitCalled = YES;
    }
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setUserInteractionEnabled:YES];
    [self inititalizeTab];
    [self initSonicPlayerView];
    [self initUserViews];
}
- (void) initSonicPlayerView
{
    self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self sonicPlayerViewMaxFrame]];
    [self addSubview:self.sonicPlayerView];
}

- (void) initUserViews
{
    self.profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageMaxFrame]];
    [self.profileImageView.layer setCornerRadius:22.0];
    [self.profileImageView.layer setRasterizationScale:2.0];
    [self.profileImageView.layer setShouldRasterize:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self addSubview:self.profileImageView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelMaxFrame]];
    [self addSubview:self.usernameLabel];
}
- (void) inititalizeTab
{
    self.tabsView = [[UIView alloc] initWithFrame:[self tabsViewMaxFrame]];
    [self.tabsView setUserInteractionEnabled:YES];
    [self addSubview:self.tabsView];
    
    self.likesTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.likesTabButton.frame = [self likesButtonFrame];
    [self.likesTabButton setTitle:@"Likes" forState:UIControlStateNormal];
    self.likesTabButton.tag = LikesTabButtonTag;
    
    self.commentsTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.commentsTabButton.frame = [self commentsButtonFrame];
    [self.commentsTabButton setTitle:@"Comments" forState:UIControlStateNormal];
    self.commentsTabButton.tag = CommentsTabButtonTag;
    
    self.resonicsTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.resonicsTabButton.frame = [self resonicsButtonFrame];
    [self.resonicsTabButton setTitle:@"Resonics" forState:UIControlStateNormal];
    self.resonicsTabButton.tag = ResonicsTabButtonTag;
    [@[self.likesTabButton,self.commentsTabButton,self.resonicsTabButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [self.tabsView addSubview:button];
    }];
}

- (void) reorganizeForRatio:(CGFloat)ratio
{   
    [self.sonicPlayerView setFrame:CGRectByRatio([self sonicPlayerViewMaxFrame], [self sonicPlayerViewMinFrame], ratio)];
    [self.profileImageView setFrame:CGRectByRatio([self profileImageMaxFrame], [self profileImageMinFrame], ratio)];
    [self.usernameLabel setFrame:CGRectByRatio([self usernameLabelMaxFrame], [self usernameLabelMinFrame], ratio)];
    [self.tabsView setFrame:CGRectByRatio([self tabsViewMaxFrame], [self tabsViewMinFrame], ratio)];
}

- (void) setButtonTargets:(id)target selector:(SEL) selector
{
    [@[self.likesTabButton,self.commentsTabButton,self.resonicsTabButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }];
}
@end
