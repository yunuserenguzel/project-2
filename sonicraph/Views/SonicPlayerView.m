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

@property UIImageView* pausedImageView;

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
    return CGRectMake(0.0, 320.0, 320.0, 1.5);
}

- (CGRect) pausedImageViewFrame
{
    CGFloat w = 70.0 / 1.5, h = 74.0 / 1.5;
    return CGRectMake(160.0-(w*0.5), 160.0-(h*0.5), w, h);
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
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.soundSlider = [[SNCSoundSlider alloc] init];
    [self.soundSlider setFrame:[self soundSliderFrame]];
    [self.soundSlider setMinimumValue:0.0];
    [self.soundSlider setMaximumValue:0.1];
    [self.soundSlider setBaseColor:[UIColor clearColor]];
    [self addSubview:self.soundSlider];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
    
    self.pausedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paused.png"]];
    [self.pausedImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.pausedImageView setFrame:[self pausedImageViewFrame]];
    [self.pausedImageView setHidden:YES];
    [self.imageView addSubview:self.pausedImageView];

}

- (void) showPausedImageView
{
    [self.pausedImageView setAlpha:0.25];
    [self.pausedImageView setHidden:NO];
    CGFloat duration = 0.5;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pausedImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:duration * 0.4 animations:^{
        [self.pausedImageView setAlpha:0.6];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration * 0.4 animations:^{
            [self.pausedImageView setAlpha:0.25];
        } completion:^(BOOL finished) {
            self.pausedImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [self.pausedImageView setHidden:YES];
        }];
    }];

}

- (void) tapped
{
    if([self.audioPlayer isPlaying]){
        [self pause];
        [self showPausedImageView];
    }
    else{
        [self play];
    }
}


- (void)setSonicUrl:(NSURL *)sonicUrl
{
    if([[self.sonicUrl path] isEqualToString:sonicUrl.path] != YES){
        _sonicUrl = sonicUrl;
        [self setSonic:nil];
        self.imageView.image = SonicPlaceholderImage;
        [SNCAPIManager getSonic:sonicUrl withSonicBlock:^(SonicData *sonic, NSError *error) {
            if([self.sonicUrl.path isEqualToString:sonic.remoteSonicDataFileUrl.path]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sonic = sonic;
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
    if(sonic == nil){
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    else {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:nil];
        [self.soundSlider setMaximumValue:self.audioPlayer.duration];
    }
    [self.soundSlider setValue:0.0];
}

- (void)setFrame:(CGRect)frame
{
//    frame.size = SonicPlayerViewSize;
    [super setFrame:frame];
    CGRect imageViewframe = [self imageViewFrame];;
    imageViewframe.size = frame.size;
    [self.imageView setFrame:imageViewframe];
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
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
