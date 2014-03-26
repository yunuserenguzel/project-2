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

//@interface LoadingView : UIView
//@property (nonatomic) CGFloat ratio;
//@end
//
//@implementation LoadingView
//
//- (void)setRatio:(CGFloat)ratio
//{
//    _ratio = ratio;
//    [self setNeedsDisplay];
//}
//
//- (void)drawRect:(CGRect)rect
//{
////    [super drawRect:rect];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
//    CGContextFillRect(context, self.bounds);
//    
//    CGRect allRect = self.bounds;
//    CGRect circleRect = CGRectMake(allRect.origin.x + 2, allRect.origin.y + 2,
//                                   allRect.size.width - 4, allRect.size.height - 4);
//    
//    // Draw background
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); // white
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1); // translucent white
//    CGContextSetLineWidth(context, 2.0);
//    CGContextFillEllipseInRect(context, circleRect);
//    CGContextStrokeEllipseInRect(context, circleRect);
//    
//    // Draw progress
//    float x = (allRect.size.width / 2);
//    float y = (allRect.size.height / 2);
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); // white
//    CGContextMoveToPoint(context, x, y);
//    CGContextAddArc(context, x, y, (allRect.size.width - 4) / 2, -(M_PI / 2),
//                    (self.ratio * 2 * M_PI) - M_PI / 2, 0);
//    CGContextClosePath(context);
//    CGContextFillPath(context);
//}
//
//@end


@interface SonicPlayerView () <AVAudioPlayerDelegate>

@property UIImageView* imageView;

@property AVAudioPlayer* audioPlayer;

@property SNCSoundSlider* soundSlider;

@property NSTimer* timer;

@property UIImageView* pausedImageView;

@property SNCPreloaderImageView* preloader;

@end

@implementation SonicPlayerView
{
//    LoadingView* loadingView;
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

- (CGRect) pausedImageViewFrame
{
    CGFloat w = 70.0 / 1.5, h = 74.0 / 1.5;
    return CGRectMake(160.0-(w*0.5), 160.0-(h*0.5), w, h);
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
    [self.longPressGesture setMinimumPressDuration:1.5];
    [self addGestureRecognizer:self.longPressGesture];
    
    self.pausedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paused.png"]];
    [self.pausedImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.pausedImageView setFrame:[self pausedImageViewFrame]];
    [self.pausedImageView setHidden:YES];
    [self.imageView addSubview:self.pausedImageView];
    
    self.preloader = [[SNCPreloaderImageView alloc] initWithFrame:[self preloaderViewFrame]];
    [self.imageView addSubview:self.preloader];
    [self.preloader setHidden:YES];

}
- (void) longPress:(UILongPressGestureRecognizer* )longGesture
{
//    NSLog(@"state: %d", longGesture.state);
    if([longGesture state] == UIGestureRecognizerStateBegan){
        [self stop];
        [self play];
    }
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
             });
         }
     }
     andRefreshBlock:^(CGFloat ratio, NSURL* sonicUrl) {
//         if([self.sonicUrl.path isEqualToString:sonicUrl.path])
//         {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 loadingView.ratio = ratio;
//             });
//         }
     }
     andErrorBlock:^(NSError *error) {
         UIButton* retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
         [retryButton setImage:[UIImage imageNamed:@"retry_icon.png"] forState:UIControlStateNormal];
         retryButton.frame = [self imageViewFrame];
         [self addSubview:retryButton];
         [retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
     }];
}

- (void) retry:(UIButton*)retryButton
{
    [retryButton removeFromSuperview];
    [self downloadSonicData];
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
    [self.audioPlayer setCurrentTime:0.1];
    [self.soundSlider setValue:0.1];
}

- (void)pause
{
    [self.timer invalidate];
    [self.audioPlayer pause];
}


@end
