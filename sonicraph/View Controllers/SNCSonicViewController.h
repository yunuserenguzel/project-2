//
//  SNCSonicViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/22/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Sonic.h"
#import "SonicViewControllerHeaderView.h"

typedef enum SonicViewControllerInitiationType {
    SonicViewControllerInitiationTypeCommentWrite = 101,
    SonicViewControllerInitiationTypeCommentRead = 102,
    SonicViewControllerInitiationTypeLikeRead = 103,
    SonicViewControllerInitiationTypeResonicRead = 104
} SonicViewControllerInitiationType;

typedef enum ContentType {
    ContentTypeNone,
    ContentTypeComments,
    ContentTypeLikes,
    ContentTypeResonics
} ContentType;

@interface SNCSonicViewController : UIViewController <SegmentedBarDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property UITableView* tableView;
@property (nonatomic) Sonic* sonic;

@property SonicViewControllerHeaderView* headerView;
@property UIImageView* headerViewShadow;

@property NSArray* likesContent;
@property NSArray* commentsContent;
@property NSArray* resonicsContent;

@property UIView* tabActionBarView;

@property UITextField* commentField;
@property UIButton* commentSubmitButton;
@property UIView* writeCommentView;

@property UIButton* likeButton;
@property UIButton* resonicButton;


@property UIView* keyboardCloser;

@property SonicViewControllerInitiationType initiationType;


- (void) initiateFor:(SonicViewControllerInitiationType)initiationType;

@end
