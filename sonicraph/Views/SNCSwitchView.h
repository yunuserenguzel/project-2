//
//  SNCSwitchView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 25/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCSwitchView : UIControl

@property (nonatomic) UIImage* image;
@property (nonatomic) UIImage* backgroundImage;

@property (readonly) UIImageView* imageView;
@property (readonly) UIImageView* backgroundImageView;

@property (readonly) UIPanGestureRecognizer* panGesture;

@property (readonly) UITapGestureRecognizer* tapGesture;

@property (readonly) UILabel* onLabel;
@property (readonly) UILabel* offLabel;

@property (nonatomic) BOOL on;


@end
