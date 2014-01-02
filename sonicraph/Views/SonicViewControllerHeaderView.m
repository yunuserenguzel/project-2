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
- (CGRect) segmentedBarMaxFrame
{
    return CGRectMake(0.0, 386.0, 320.0, 61.0);
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
- (CGRect) segmentedBarMinFrame
{
    return CGRectMake(0.0, 387.0, 320.0, 61.0);
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
    [self initUserViews];
    [self initSonicPlayerView];
    [self inititalizeTab];
    
    self.tapToTopView = [[UIView alloc] initWithFrame:[self sonicPlayerViewMinFrame]];
    [self.tapToTopView setHidden:YES];
    [self.tapToTopView setUserInteractionEnabled:YES];
    [self insertSubview:self.tapToTopView aboveSubview:self.sonicPlayerView];

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
    self.segmentedBar = [[SegmentedBar alloc] initWithFrame:[self segmentedBarMaxFrame]];
    [self addSubview:self.segmentedBar];
    
    NSArray* segmentItems = @[
      [SegmentedBarItem itemWithNormalImage:[UIImage imageNamed:@"HeartGrey.png"]
                              selectedImage:[UIImage imageNamed:@"HeartPink.png"]
                                      title:@"Likes"
                                   subtitle:@"215"],
      [SegmentedBarItem itemWithNormalImage:[UIImage imageNamed:@"CommentGrey.png"]
                              selectedImage:[UIImage imageNamed:@"CommentPink.png"]
                                      title:@"Comments"
                                   subtitle:@"215"],
      [SegmentedBarItem itemWithNormalImage:[UIImage imageNamed:@"ReSonicGrey.png"]
                              selectedImage:[UIImage imageNamed:@"ReSonicPink.png"]
                                      title:@"Resonics"
                                   subtitle:@"215"],
    ];
    [self.segmentedBar setItems:segmentItems];

}
- (void) addTargetForTapToTop:(id)target action:(SEL)selector
{
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self.tapToTopView addGestureRecognizer:tapGesture];
}

- (void) reorganizeForRatio:(CGFloat)ratio
{   
    [self.sonicPlayerView setFrame:CGRectByRatio([self sonicPlayerViewMaxFrame], [self sonicPlayerViewMinFrame], ratio)];
    [self.profileImageView setFrame:CGRectByRatio([self profileImageMaxFrame], [self profileImageMinFrame], ratio)];
    [self.usernameLabel setFrame:CGRectByRatio([self usernameLabelMaxFrame], [self usernameLabelMinFrame], ratio)];
    [self.segmentedBar setFrame:CGRectByRatio([self segmentedBarMaxFrame], [self segmentedBarMinFrame], ratio)];
    if(ratio < 1.0){
        [self.sonicPlayerView stop];
        [self.tapToTopView setHidden:NO];
        [self.sonicPlayerView setUserInteractionEnabled:NO];
    }
    else {
        [self.tapToTopView setHidden:YES];
        [self.sonicPlayerView setUserInteractionEnabled:YES];
    }
}


@end
