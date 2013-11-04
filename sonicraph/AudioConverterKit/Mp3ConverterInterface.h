//
//  Mp3ConverterInterface.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/4/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MP3Converter.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void (^Block)();

@interface Mp3ConverterInterface : NSObject <MP3ConverterDelegate>

//+ (Mp3ConverterInterface*) sharedInstance;

- (void)convertMp3FromFile:(NSURL *)from toOutputName:(NSString *)outputName andCompletionBlock:(Block)completionBlock;

- (void) convertMp3FromFile:(NSURL*)from toOutputName:(NSString *)outputName withStarting:(CGFloat)start andLength:(CGFloat)length andCompletionBlock:(Block)completionBlock;

@end
