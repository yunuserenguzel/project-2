//
//  SNCShareControllerViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/7/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicData.h"
#import "SNCResizableTextView.h"
@interface SNCShareViewController : UIViewController <UIGestureRecognizerDelegate,SNCResizableTextViewProtocol>

@property (nonatomic) SonicData* sonic;

@end