//
//  SNCRecordViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/20/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SNCPreviewViewController.h"

typedef enum SonicCameraType {
    SonicCameraTypePhotoFirst,
    SonicCameraTypeSoundFirst
} SonicCameraType;

@interface SNCCameraViewController ()

@property UIImageView* maskView;
@property UIView* cameraView;
@property UIActivityIndicatorView* activityIndicator;
@property UITapGestureRecognizer* tapRecognizer;
@property UIButton* recordButton;
@property UIButton* flashButton;
@property UIView* cameraFeaturesBar;
@property SonicCameraType cameraType;
@end

@implementation SNCCameraViewController
{
    NSInteger tapIndex;
    UIImage* capturedImage;
    NSData* capturedAudio;
}

- (CGRect) cameraFeaturesBarFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}
- (CGRect) cameraViewFrame
{
    return CGRectMake(0.0, 0.0 , 320.0, 426.0);
}
- (CGRect) visibleRectFrame
{
    return CGRectMake(0.0, 44.0, 320.0, 320.0);
}
- (CGRect) recordButtonFrame
{
    return CGRectMake(self.view.frame.size.width*0.5 - 33.0, 400.0, 66.0, 66.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraType = SonicCameraTypePhotoFirst;
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.cameraView = [[UIView alloc] initWithFrame:[self cameraViewFrame]];
    [self.view addSubview:self.cameraView];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(initializeMediaManager) object:nil] start];
    
    [self initializeMaskView];
    [self initializeCameraFeaturesBar];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"Camera Button.png"] forState:UIControlStateNormal];
//    [self.recordButton setTitle:@"Take" forState:UIControlStateNormal];
    [self.recordButton setFrame:[self recordButtonFrame]];
    if(self.cameraType == SonicCameraTypeSoundFirst){
        [self.recordButton addTarget:self action:@selector(startAudioRecording) forControlEvents:UIControlEventTouchUpInside];
    } else {
        
        [self.recordButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.recordButton];
    
    
	// Do any additional setup after loading the view.
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) previewSonic
{
    if(capturedImage != nil && capturedAudio != nil){
        [self performSegueWithIdentifier:PreviewSonicSegue sender:self];
    }
}

- (void) takePicture
{
    [self.activityIndicator startAnimating];
    
    ImageBlock block = ^(UIImage *image) {
        CGFloat xScale = image.size.width / [self cameraViewFrame].size.width;
        CGFloat yScale = image.size.height / [self cameraViewFrame].size.height;
        CGFloat x = [self visibleRectFrame].origin.x * xScale;
        CGFloat y = [self visibleRectFrame].origin.y * yScale;
        CGFloat w = [self visibleRectFrame].size.width * xScale;
        CGFloat h = [self visibleRectFrame].size.height * yScale;
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        capturedImage = [image cropForRect:CGRectMake(x, y, w, h)];
        
        UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
        capturedImage = [capturedImage imageByScalingAndCroppingForSize:CGSizeMake(620.0, 620.0)];
        
        UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
        
        [self.activityIndicator stopAnimating];
        [self.tapRecognizer setEnabled:YES];
        if(self.cameraType == SonicCameraTypePhotoFirst){
            [self startAudioRecording];
            [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [self.recordButton addTarget:self action:@selector(stopAudioRecording) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [self stopAudioRecording];
        }
        
    };
    
    [self.mediaManager performSelector:@selector(takePictureWithCompletionBlock:) withObject:block afterDelay:0.5];
    
//    [self.mediaManager takePictureWithCompletionBlock:];
}

- (void) startAudioRecording
{
    [self.mediaManager startAuidoRecording];
    if(self.cameraType == SonicCameraTypeSoundFirst){
        [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) stopAudioRecording
{
    
    [self.mediaManager stopAudioRecording];
    [self previewSonic];
    
}

- (void) initializeCameraFeaturesBar
{
    self.cameraFeaturesBar = [[UIView alloc] initWithFrame:[self cameraFeaturesBarFrame]];
    [self.cameraFeaturesBar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.cameraFeaturesBar];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton setTitle:@"Off" forState:UIControlStateNormal];
//    self.flashButton.titleLabel setFont:<#(UIFont *)#>
    [self.flashButton setImage:[UIImage imageNamed:@"Camera Flash.png"] forState:UIControlStateNormal];
//    [self.flashButton setImageEdgeInsets:UIEdgeInsetsMake(14.0, .0, 15.0, 60.0)];

    [self.flashButton setFrame:CGRectMake(11.0, 0.0, 88.0, 44.0)];
    [self.cameraFeaturesBar addSubview:self.flashButton];
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeMediaManager
{
    self.mediaManager = [[SonicraphMediaManager alloc] initWithView:self.cameraView];
    [self.mediaManager setDelegate:self];

}

- (void)viewDidAppear:(BOOL)animated
{

}

-(void)manager:(SonicraphMediaManager *)manager audioDataReady:(NSData *)data
{
    capturedAudio = data;
    NSLog(@"%@",data);
    [self previewSonic];
}

- (void) initializeMaskView
{
    self.maskView = [UIImageView new];
    [self.maskView setFrame:[self cameraViewFrame]];
    [self.maskView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.maskView];
    
    // Ensure it's auto-resolution
    // w x h, transparent, and with device's default scaling (required for retina!)
    
    UIGraphicsBeginImageContextWithOptions(self.maskView.frame.size, NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, self.maskView.frame.size.width, self.maskView.frame.size.height));
    
    //    CGRect inRectFrame = CGRectMake(7.0, 50.0, 306.0, 306.0);
    CGContextClearRect(context, [self visibleRectFrame]);
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.2);
//    CGContextStrokeRect(context, [self visibleRectFrame]);
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    [self.maskView setImage:maskImage];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[SNCPreviewViewController class]]){
        Sonic* sonic = [[Sonic alloc] initWithImage:capturedImage
                                                    andSound:capturedAudio
                                                      withId:[NSString stringWithFormat:@"sonic%f",[NSDate timeIntervalSinceReferenceDate]]];
        SNCPreviewViewController* previewController = segue.destinationViewController;
        [previewController setSonic:sonic];
        capturedAudio = nil;
        capturedImage = nil;
        tapIndex = 0;
    }
}

@end
