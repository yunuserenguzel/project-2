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
#import "SNCResourceHandler.h"
#import "SNCPreloaderImageView.h"
#import "SNCEqualizerView.h"

@interface SonicPlayerView () <AVAudioPlayerDelegate>

@property UIImageView* imageView;

@property AVAudioPlayer* audioPlayer;

@property SNCSoundSlider* soundSlider;

@property NSTimer* timer;

@property SNCPreloaderImageView* preloader;

@property UIImageView* playImageView;

@property SNCEqualizerView* equalizerView;

@end

@implementation SonicPlayerView
{
}

- (CGRect) imageViewFrame
{
    CGRect frame = CGRectZero;
    frame.size = self.frame.size;
    return frame;
}

- (CGRect) soundSliderFrame
{
    return CGRectMake(0.0, 320.0, 320.0, 1.5);
}

- (CGRect) playImageViewFrame
{
    return CGRectMake(280.0, 280.0, 30.0, 30.0);
}

- (CGRect) equalizerViewFrame
{
    return CGRectMake(285.0, 290.0, 20.0, 20.0);
}

- (CGRect) preloaderViewFrame
{
    CGRect frame = [self imageViewFrame];
    frame.origin.x = (frame.size.width - frame.size.width * 0.3) * 0.5;
    frame.origin.y = (frame.size.height - frame.size.height * 0.3) * 0.5;
    frame.size.width = frame.size.width * 0.3;
    frame.size.height = frame.size.height * 0.3;
    return frame;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
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
    [self.soundSlider setMinimumValue:0.1];
    [self.soundSlider setMaximumValue:1.0];
    [self.soundSlider setBaseColor:[UIColor clearColor]];
    [self addSubview:self.soundSlider];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:self.tapGesture];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.longPressGesture setMinimumPressDuration:1];
    [self addGestureRecognizer:self.longPressGesture];
    
    
    self.preloader = [[SNCPreloaderImageView alloc] initWithFrame:[self preloaderViewFrame]];
    [self.imageView addSubview:self.preloader];
    [self.preloader setHidden:YES];
    
    self.playImageView = [[UIImageView alloc] initWithFrame:[self playImageViewFrame]];
    [self.playImageView setImage:[UIImage imageNamed:@"playSonicImage.png"]];
    [self addSubview:self.playImageView];
    
}

- (void) longPress:(UILongPressGestureRecognizer* )longGesture
{
    if([longGesture state] == UIGestureRecognizerStateBegan){
        [self stop];
        [self play];
    }
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
    if(![[self.sonicUrl path] isEqualToString:sonicUrl.path]){
        [self.soundSlider setValue:0.0];
        [self setSonic:nil];
        _sonicUrl = sonicUrl;
        [self downloadSonicData];
    }
}

- (void) downloadSonicData
{
    [self.preloader setHidden:NO];
    [[SNCResourceHandler sharedInstance]
     getSonicDataWithUrl:self.sonicUrl
     withCompletionBlock:^(SonicData *sonic) {
         if([self.sonicUrl.path isEqualToString:sonic.remoteSonicDataFileUrl.path]){
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.sonic = sonic;
                 if(self.shouldAutoPlay)
                 {
                     [self play];
                 }
             });
         }
     }
     andRefreshBlock:^(CGFloat ratio, NSURL* sonicUrl) {

     }
     andErrorBlock:^(NSError *error) {
         [self downloadSonicData];
     }];
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
    [self.preloader setHidden:YES];
    self.imageView.image = self.sonic.image;
    if(sonic == nil){
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    else {
        NSError* error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:&error];
        [self.audioPlayer setCurrentTime:0.1];
        [self.soundSlider setMaximumValue:self.audioPlayer.duration];
    }
    [self.soundSlider setValue:0.1];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect imageViewframe = [self imageViewFrame];;
    imageViewframe.size = frame.size;
    [self.imageView setFrame:imageViewframe];
}

- (void) timerUpdate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.soundSlider setValue:self.audioPlayer.currentTime];
        if(![self.audioPlayer isPlaying]){
            [self stop];
        }
    });
}

- (void)play
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.equalizerView removeFromSuperview];
        self.equalizerView = [[SNCEqualizerView alloc] initWithFrame:[self equalizerViewFrame]];
        [self addSubview:self.equalizerView];
        [self.equalizerView startAnimating];
    });
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [self.audioPlayer play];
    [self.playImageView setHidden:YES];
    if(self.timer == nil || ![self.timer isValid]){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [self.timer setTolerance:0.01];
    }
}

- (void)stop
{
    [self.playImageView setHidden:NO];
    [self.equalizerView stopAnimating];
    [self.timer invalidate];
    [self.audioPlayer stop];
    [self.audioPlayer setCurrentTime:0.1];
    [self.soundSlider setValue:0.0];
}

- (void)pause
{
    [self.playImageView setHidden:NO];
    [self.equalizerView stopAnimating];
    [self.timer invalidate];
    [self.audioPlayer pause];
}


@end
