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

@property (readonly) UIImageView* imageView;

@property (readonly) UILabel* textLabel;

@property (readonly) UITapGestureRecognizer* tapGesture;


@property (nonatomic) BOOL on;


@end
