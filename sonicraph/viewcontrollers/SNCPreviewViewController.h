//
//  SNCPreviewViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/26/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"
#import <AVFoundation/AVFoundation.h>
@interface SNCPreviewViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic) Sonic* sonic;


@end