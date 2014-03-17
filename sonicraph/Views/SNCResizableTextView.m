//
//  SNCReziableTextView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 08/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCResizableTextView.h"

@implementation SNCResizableTextView

- (CGRect) textFieldPassiveFrame
{
    return CGRectMake(7.0, 7.0, 300.0, 30.0);
}

- (CGRect) textFieldActiveFrame
{
    return CGRectMake(30.0, 7.0, 240.0, 30.0);
}

- (CGRect) doneButtonFrame
{
    return CGRectMake(270.0, 0.0, 50.0, 46.0);
}

- (CGRect) cancelButtonFrame
{
    return CGRectMake(0.0, 0.0, 30.0, 48.0);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        [self initViews];
        
    }
    return self;
}

- (void) initViews
{
    self.growingTextView = [[HPGrowingTextView alloc] initWithFrame:[self textFieldPassiveFrame]];
    [self.growingTextView setMinNumberOfLines:1];
    [self.growingTextView setMaxNumberOfLines:5];
    self.growingTextView.delegate = self;
    [self.growingTextView setMinHeight:[self textFieldPassiveFrame].size.height];
    [self.growingTextView setContentInset:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [self.growingTextView setPlaceholder:@"Say something nice.."];
    [self.growingTextView setFont:[self.growingTextView.font fontWithSize:14.0]];
    [self.growingTextView setBackgroundColor:[UIColor whiteColor]];
    [self.growingTextView setUserInteractionEnabled:YES];
    [self.growingTextView.layer setCornerRadius:5.0];
    [self.growingTextView setClipsToBounds:YES];
    [self.growingTextView.layer setBorderWidth:0.0];
//    [self.growingTextView.layer setBorderColor:self.tabActionBarView.backgroundColor.CGColor];
    [self addSubview:self.growingTextView];
    [self growingTextView:self.growingTextView willChangeHeight:self.growingTextView.frame.size.height];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [self.doneButton setImage:[UIImage imageNamed:@"AddCommentIcon.png"] forState:UIControlStateNormal];
    [self.doneButton setFrame:[self doneButtonFrame]];
    [self.doneButton setHidden:YES];
    [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
    [self addSubview:self.doneButton];
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setFrame:[self cancelButtonFrame]];
    [self.cancelButton setHidden:YES];
    [self.cancelButton setImage:[UIImage imageNamed:@"CancelCommentandTag.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.transform = CGAffineTransformMakeTranslation(-320.0, 0.0);
    [self addSubview:self.cancelButton];
}

- (void) done
{
    [self.growingTextView resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(SNCResizableTextViewDoneButtonPressed:)])
    {
        [self.delegate SNCResizableTextViewDoneButtonPressed:self];
    }
}

- (void) cancel
{
    self.growingTextView.text = @"";
    [self.growingTextView resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(SNCResizableTextViewCancelButtonPressed:)])
    {
        [self.delegate SNCResizableTextViewCancelButtonPressed:self];
    }
}

- (void) growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if (self.growingTextView.text.length > 0)
    {
        CGRect frame = self.growingTextView.frame;
        frame.size.width = [self textFieldActiveFrame].size.width;
        frame.origin.x = [self textFieldActiveFrame].origin.x;
        [self.growingTextView setFrame:frame];
        [self.doneButton setHidden:NO];
        [self.cancelButton setHidden:NO];
        self.doneButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }
    else
    {
        CGRect frame = self.growingTextView.frame;
        frame.size.width = [self textFieldPassiveFrame].size.width;
        frame.origin.x = [self textFieldPassiveFrame].origin.x;
        [self.growingTextView setFrame:frame];
        [self.doneButton setHidden:YES];
        [self.cancelButton setHidden:YES];
        self.doneButton.transform = CGAffineTransformMakeTranslation(320.0, 0.0);
        self.cancelButton.transform = CGAffineTransformMakeTranslation(-320.0, 0.0);
    }
    if([self.delegate respondsToSelector:@selector(SNCResizableTextViewDidChange:)])
    {
        [self.delegate SNCResizableTextViewDidChange:self];
    }
}

- (void) growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGRect frame = self.frame;
    frame.size.height = height + 14;
    [self setFrame:frame];
    
    if([self.delegate respondsToSelector:@selector(SNCResizableTextView:willChangeHeight:)])
    {
        [self.delegate SNCResizableTextView:self willChangeHeight:frame.size.height];
    }
}





@end
