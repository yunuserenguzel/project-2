//
//  SNCReziableTextView.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 08/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
@class SNCResizableTextView;

@protocol SNCResizableTextViewProtocol

@optional;
- (void) SNCResizableTextViewDoneButtonPressed:(SNCResizableTextView*)textView;
- (void) SNCResizableTextViewCancelButtonPressed:(SNCResizableTextView*)textView;

- (void) SNCResizableTextViewDidChange:(SNCResizableTextView *)textView;
- (void) SNCResizableTextView:(SNCResizableTextView *)textView willChangeHeight:(float)height;

@end


@interface SNCResizableTextView : UIView <HPGrowingTextViewDelegate>

@property (weak) NSObject<SNCResizableTextViewProtocol>* delegate;

@property HPGrowingTextView* growingTextView;
@property UIButton* cancelButton;
@property UIButton* doneButton;


@end
