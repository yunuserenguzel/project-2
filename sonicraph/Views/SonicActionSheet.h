//
//  SonicActionSheet.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

@interface SonicActionSheet : UIActionSheet <UIActionSheetDelegate, UIAlertViewDelegate>

@property (readonly) Sonic* sonic;

- (id) initWithSonic:(Sonic*)sonic;

@end
