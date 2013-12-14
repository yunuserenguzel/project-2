//
//  SNCPreviewViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/26/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SonicData.h"
#import <AVFoundation/AVFoundation.h>
#import "NMRangeSlider.h"
#import "TypeDefs.h"

@interface SNCEditViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic) SonicData* sonic;
@property (nonatomic) UIButton* replayButton;
@end
