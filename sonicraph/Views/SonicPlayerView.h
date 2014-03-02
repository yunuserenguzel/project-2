//
//  SonicPlayerView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/13/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicData.h"

@interface SonicPlayerView : UIView

@property (nonatomic) SonicData* sonic;

@property (nonatomic) NSURL* sonicUrl;

@property (readonly) UITapGestureRecognizer* tapGesture;

@property (readonly) UILongPressGestureRecognizer* longPressGesture;

- (void) play;

- (void) pause;

- (void) stop;

@end
