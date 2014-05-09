//
//  SonicViewControllerHeaderView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/1/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicViewControllerHeaderView.h"
#import "Configurations.h"



@implementation SonicViewControllerHeaderView
{
    BOOL isInitCalled;
}

- (CGRect) profileImageMaxFrame
{
    return CGRectMake(5.0, 5.0, 49.0, 49.0);
}
- (CGRect) fullnameLabelMaxFrame
{
    //    CGFloat w = [self.fullnameLabel.text boundingRectWithSize:CGSizeMake(240.0, 1000.0) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:self.fullnameLabel.font} context:nil].size.width;
    return CGRectMake(64.0, 5.0, 200.0, 20.0);
}
- (CGRect) usernameLabelMaxFrame
{
    return CGRectMake(64.0, 26.0, 244.0, 18.0);
}
- (CGRect) createdAtLabelMaxFrame
{
    return CGRectMake(320.0-60.0, 5.0, 55.0, 20.0);
}
- (CGRect) sonicPlayerViewMaxFrame
{
    return CGRectMake(0.0, 59.0, 320.0, 320.0);
}
- (CGRect) segmentedBarMaxFrame
{
    return CGRectMake(10.0, HeaderViewMaxHeight - 57.0, 300.0, 30.0);
}

- (CGRect) profileImageMinFrame
{
    return CGRectMake(5.0, HeaderViewMaxHeight - HeaderViewMinHeight + 5.0, 49.0, 49.0);
}
- (CGRect) fullnameLabelMinFrame
{
    return CGRectMake(64.0, HeaderViewMaxHeight - HeaderViewMinHeight + 5.0, 200.0, 20.0);
}
- (CGRect) usernameLabelMinFrame
{
    return CGRectMake(64.0, HeaderViewMaxHeight - HeaderViewMinHeight + 22.0, 244.0, 18.0);
}
- (CGRect) createdAtLabelMinFrame
{
    return CGRectMake(320.0-60.0, HeaderViewMaxHeight - HeaderViewMinHeight + 5.0, 55.0, 20.0);
}
- (CGRect) sonicPlayerViewMinFrame
{
    return CGRectMake(320.0 - 49.0 - 5.0 , HeaderViewMaxHeight - HeaderViewMinHeight + 5.0, 49.0, 49.0);
}
- (CGRect) segmentedBarMinFrame
{
    return CGRectMake(10.0, HeaderViewMaxHeight - 37.0 , 300.0, 30.0);
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
    self.profileImageView = [[FadingImageView alloc] initWithFrame:[self profileImageMaxFrame]];
//    [self.profileImageView.layer setCornerRadius:[self profileImageMaxFrame].size.height * 0.5];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self addSubview:self.profileImageView];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelMaxFrame]];
    [self.fullnameLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [self.fullnameLabel setTextColor:FullnameTextColor];
    [self addSubview:self.fullnameLabel];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelMaxFrame]];
    [self.usernameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [self.usernameLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:self.usernameLabel];
    
    self.createdAtLabel = [[UILabel alloc] initWithFrame:[self createdAtLabelMaxFrame]];
    [self.createdAtLabel setTextAlignment:NSTextAlignmentRight];
    [self.createdAtLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
    [self.createdAtLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:self.createdAtLabel];
}
- (void) inititalizeTab
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Likes",@"Comments",@"Resonics"]];
    [self addSubview:self.segmentedControl];
    [self.segmentedControl sizeToFit];
    [self.segmentedControl setFrame:[self segmentedBarMaxFrame]];
    [self.segmentedControl setTintColor:MainThemeColor];
}
- (void) addTargetForTapToTop:(id)target action:(SEL)selector
{
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self.tapToTopView addGestureRecognizer:tapGesture];
}

- (void) reorganizeForRatio:(CGFloat)ratio
{   
//    [self.sonicPlayerView setFrame:CGRectByRatio([self sonicPlayerViewMaxFrame], [self sonicPlayerViewMinFrame], ratio)];
//    [self.profileImageView setFrame:CGRectByRatio([self profileImageMaxFrame], [self profileImageMinFrame], ratio)];
//    [self.fullnameLabel setFrame:CGRectByRatio([self fullnameLabelMaxFrame], [self fullnameLabelMinFrame], ratio)];
//    [self.usernameLabel setFrame:CGRectByRatio([self usernameLabelMaxFrame], [self usernameLabelMinFrame], ratio)];
//    [self.createdAtLabel setFrame:CGRectByRatio([self createdAtLabelMaxFrame], [self createdAtLabelMinFrame], ratio)];
    [self.segmentedControl setFrame:CGRectByRatio([self segmentedBarMaxFrame], [self segmentedBarMinFrame], ratio)];
    if(ratio < 1.0){
//        [self.sonicPlayerView stop];
        [self.tapToTopView setHidden:NO];
//        [self.sonicPlayerView setUserInteractionEnabled:NO];
    }
    else {
        [self.tapToTopView setHidden:YES];
//        [self.sonicPlayerView setUserInteractionEnabled:YES];
    }
}


@end
