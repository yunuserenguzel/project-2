//
//  UIImage+imageForSoundData.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/19/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVURLAsset;


@interface UIImage (imageForSoundData)

+ (UIImage *) imageWithSoundAsset:(AVURLAsset *)songAsset;

@end
