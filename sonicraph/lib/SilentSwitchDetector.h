//
//  SilentSwitchDetector.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 03/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
typedef void(^SilentSwitchDetectorBlock)(BOOL success, BOOL silent);

@interface SilentSwitchDetector : NSObject

+ (void)ifMute:(SilentSwitchDetectorBlock)then;
@end
