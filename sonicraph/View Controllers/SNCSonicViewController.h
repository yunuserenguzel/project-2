//
//  SNCSonicViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/22/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

typedef enum SonicViewControllerInitiationType {
    SonicViewControllerInitiationTypeCommentWrite = 101,
    SonicViewControllerInitiationTypeCommentRead = 102,
    SonicViewControllerInitiationTypeLikeRead = 103,
    SonicViewControllerInitiationTypeResonicRead = 104
} SonicViewControllerInitiationType;

@interface SNCSonicViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) Sonic* sonic;

- (void) initiateFor:(SonicViewControllerInitiationType)initiationType;

@end
