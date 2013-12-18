//
//  SonicPlayerView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/13/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicPlayerView.h"
#import "SNCAPIManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SNCSoundSlider.h"
#import "Configurations.h"

@interface SonicPlayerView () <AVAudioPlayerDelegate>

@property UIImageView* imageView;

@property AVAudioPlayer* audioPlayer;

@property SNCSoundSlider* soundSlider;

@property NSTimer* timer;

@end

@implementation SonicPlayerView
{
    
}

- (CGRect) imageViewFrame
{
    CGRect frame = CGRectZero;
    frame.size = SonicSize;
    frame.origin = CGPointZero;
    return frame;
}

- (CGRect) soundSliderFrame
{
    return CGRectMake(0.0, 320.0, 320.0, 1.0);
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (id) init
{
    if (self = [super init]){
        [self setFrame:CGRectMake(0.0, 0.0, 320.0, 321.0)];
        [self initViews];
        
    }
    return self;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.timer invalidate];
}

- (void) initViews
{
    [self initializeImageView];
    
    self.soundSlider = [[SNCSoundSlider alloc] init];
    [self.soundSlider setFrame:[self soundSliderFrame]];
    [self.soundSlider setMinimumValue:0.0];
    [self.soundSlider setMaximumValue:0.1];
    [self addSubview:self.soundSlider];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}

- (void) tapped
{
    if([self.audioPlayer isPlaying]){
        [self pause];
    }
    else{
        [self play];
    }
}


- (void)setSonicUrl:(NSURL *)sonicUrl
{
    if([[self.sonicUrl path] isEqualToString:sonicUrl.path] != YES){
        _sonicUrl = sonicUrl;
        self.imageView.image = nil;
        [SNCAPIManager getSonic:sonicUrl withSonicBlock:^(SonicData *sonic, NSError *error) {
            if(self.sonicUrl == sonic.remoteSonicDataFileUrl){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sonic = sonic;
                    //                self.imageView.image = sonic.image;
                });
            }
        }];
    }
}


- (void) initializeImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageView setClipsToBounds:YES];
    [self addSubview:self.imageView];
}

- (void)setSonic:(SonicData *)sonic
{
    _sonic = sonic;
    self.imageView.image = self.sonic.image;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:nil];
    [self.soundSlider setMaximumValue:self.audioPlayer.duration];
    [self.soundSlider setValue:0.0];
}

- (void)setFrame:(CGRect)frame
{
    frame.size = SonicPlayerViewSize;
    [super setFrame:frame];
}

- (void) timerUpdate
{
//    NSLog(@"%f",self.audioPlayer.currentTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.soundSlider setValue:self.audioPlayer.currentTime];
    });
    if(![self.audioPlayer isPlaying]){
        [self.timer invalidate];
    }
}

- (void)play
{
    [self.audioPlayer play];
    if(self.timer == nil || ![self.timer isValid]){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [self.timer setTolerance:0.01];
    }
}

- (void)stop
{
    [self.timer invalidate];
    [self.audioPlayer stop];
}

- (void)pause
{
    [self.timer invalidate];
    [self.audioPlayer pause];
}


@end
