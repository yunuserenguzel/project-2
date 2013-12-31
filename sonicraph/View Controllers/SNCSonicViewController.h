//
//  SNCSonicViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/22/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

@interface SNCSonicViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Sonic* sonic;


@end
