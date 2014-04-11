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
#import "SNCProfileViewController.h"
#import "TypeDefs.h"
#import "UIViewController+CustomMethods.h"
#import "SonicActionSheet.h"
#import "SNCResizableTextView.h"


typedef enum SonicViewControllerInitiationType {
    SonicViewControllerInitiationTypeNone = 0,
    SonicViewControllerInitiationTypeLikeSelected = 1,
    SonicViewControllerInitiationTypeResonicSelected = 2,
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

@interface SNCSonicViewController : UIViewController
<SNCResizableTextViewProtocol,
UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,OpenProfileProtocol,
UIAlertViewDelegate, UIActionSheetDelegate>

@property UITableView* tableView;
@property (nonatomic) Sonic* sonic;

@property SonicActionSheet* sonicActionSheet;

@property SonicViewControllerHeaderView* headerView;

@property NSMutableArray* likesContent;
@property NSMutableArray* commentsContent;
@property NSMutableArray* resonicsContent;

@property UIView* tabActionBarView;

@property SNCResizableTextView* writeCommentView;
@property BOOL shouldAutoPlay;

@property UIButton* likeButton;
@property UIButton* resonicButton;

@property (nonatomic) UITapGestureRecognizer* closeKeyboardTapGesture;

@property SonicViewControllerInitiationType initiationType;

- (void) initiateFor:(SonicViewControllerInitiationType)initiationType;

@end
