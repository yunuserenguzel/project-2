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

typedef enum SonicViewControllerInitiationType {
    SonicViewControllerInitiationTypeNone = 0,
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

@interface SNCSonicViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,OpenProfileProtocol, UIAlertViewDelegate>

@property UITableView* tableView;
@property (nonatomic) Sonic* sonic;

@property SonicViewControllerHeaderView* headerView;

@property NSMutableArray* likesContent;
@property NSMutableArray* commentsContent;
@property NSMutableArray* resonicsContent;

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
