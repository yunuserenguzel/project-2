//
//  SNCRecordViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/20/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SNCEditViewController.h"
#import "Configurations.h"
#import "SNCTabbarController.h"
#import "SNCSoundSlider.h"
#import "UIImage+Resize.h"


#define SonicSoundMaxTime 30.0

#define RecordButtonCameraImage [UIImage imageNamed:@"Camera Button.png"]
#define RecordButtonMicrophoneImage [UIImage imageNamed:@"Sound Button.png"]

typedef enum SonicRecordType {
    SonicRecordTypePhotoFirst,
    SonicRecordTypeSoundFirst
} SonicRecordType;

@interface SNCCameraViewController ()

@property UIImageView* maskView;
@property UIView* cameraView;
@property UIActivityIndicatorView* activityIndicator;
@property UITapGestureRecognizer* tapRecognizer;
@property UIButton* recordButton;
@property UIButton* flashButton;
@property UIView* cameraFeaturesBar;
@property SonicRecordType recordType;

@property SNCSoundSlider* soundTimeSlider;
@property NSTimer* soundTimer;
@property NSDate* soundTimerInitialFireDate;
//@property UISwitch* recordTypeSwitch;
@property UISegmentedControl* recordTypeSwitch;
@property UIButton* cancelButton;

@property UIButton* cameraTypeToggleButton;

@end

@implementation SNCCameraViewController
{
    NSInteger tapIndex;
    UIImage* capturedImage;
    NSData* capturedAudio;
    BOOL isMainCamera;
}

-(CGRect) flashButtonFrame
{
    return CGRectMake(0.0, 10.0, 44.0, 44.0);
}

- (CGRect) cameraTypeToggleButtonFrame
{
    return CGRectMake(self.view.frame.size.width - 44.0, 10.0, 44.0, 44.0);
}

- (CGRect) recordTypeSwitchFrame
{
    return CGRectMake(70.0, 15.0, 180.0, 32.0);
}
- (CGRect) cameraFeaturesBarFrame
{
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}
- (CGRect) cameraViewFrame
{
    return CGRectMake(0.0, 22.0 , 320.0, 426.0);
}
- (CGRect) visibleRectFrame
{
    return CGRectMake(0.0, 44.0, 320.0, 320.0);
}
- (CGRect) recordButtonFrame
{
    return CGRectMake(self.view.frame.size.width*0.5 - 33.0, self.view.frame.size.height-88.0, 66.0, 66.0);
}

-(CGRect) soundTimeSliderFrame
{
    return CGRectMake(0.0, 390.0, 320.0, 1.0);
}

-(CGRect) cancelButtonFrame
{
    return CGRectMake(320.0-80.0, self.view.frame.size.height-88.0, 66.0, 66.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recordType = SonicRecordTypeSoundFirst;
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.cameraView = [[UIView alloc] initWithFrame:[self cameraViewFrame]];
    [self.view addSubview:self.cameraView];
    [[[NSThread alloc] initWithTarget:self selector:@selector(initializeMediaManager) object:nil] start];
    
    [self initializeMaskView];
    [self initializeCameraFeaturesBar];
    [self initializeSoundTimeSlider];
    [self initializeCancelButton];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"Camera Button.png"] forState:UIControlStateNormal];
    [self.recordButton setFrame:[self recordButtonFrame]];
    [self.recordTypeSwitch setHidden:NO];
    [self.view addSubview:self.recordButton];
    
	// Do any additional setup after loading the view.
}

- (void) recordButtonPressed
{
    [self.recordTypeSwitch setHidden:YES];
    if(self.recordType == SonicRecordTypeSoundFirst){
        [self startAudioRecording];
    } else {
        [self takePicture];
    }
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) previewSonic
{
    if(capturedImage != nil && capturedAudio != nil){
        [self performSegueWithIdentifier:EditSonicSegue sender:self];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.recordTypeSwitch setSelectedSegmentIndex:0];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.mediaManager startCamera];

    [self.recordTypeSwitch setHidden:NO];
    [self.activityIndicator stopAnimating];
    [self.soundTimeSlider setValue:0.0];
    [self.recordButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if(self.recordType == SonicRecordTypeSoundFirst){
        [self.recordButton setImage:[UIImage imageNamed:@"Sound Button.png"] forState:UIControlStateNormal];
    } else {
        [self.recordButton setImage:[UIImage imageNamed:@"Camera Button.png"] forState:UIControlStateNormal];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO  animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
    [self.soundTimer invalidate];
}

- (void) takePicture
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
    [self.recordButton addSubview:self.activityIndicator];
    [self.activityIndicator setFrame:CGRectMake(0.0, 0.0, self.recordButton.frame.size.width, self.recordButton.frame.size.height)];
    [self.activityIndicator startAnimating];
    [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    ImageBlock block = ^(UIImage *image) {
        [self performSelector:@selector(formatCapturedImage:) withObject:image afterDelay:0.0];
        if(self.recordType == SonicRecordTypePhotoFirst){
            [self startAudioRecording];
        }
        if(self.recordType == SonicRecordTypeSoundFirst){
            [self stopAudioRecording];
        }
    };
    [self.mediaManager performSelector:@selector(takePictureWithCompletionBlock:) withObject:block afterDelay:0.5];
}

- (void) formatCapturedImage:(UIImage*)image
{
    image = [image resizedImage:CGSizeMake(640.0, image.size.height/(image.size.width/640.0)) interpolationQuality:kCGInterpolationHigh];
    
    CGFloat xScale = image.size.width / [self cameraViewFrame].size.width;
    CGFloat yScale = image.size.height / [self cameraViewFrame].size.height;
    CGFloat x = [self visibleRectFrame].origin.x * xScale;
    CGFloat y = [self visibleRectFrame].origin.y * yScale;
    CGFloat w = [self visibleRectFrame].size.width * xScale;
    CGFloat h = [self visibleRectFrame].size.height * yScale;
    
    image = [image cropForRect:CGRectMake(x, y, w, h)];
    
    capturedImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.33)];
    
    if(self.recordType == SonicRecordTypeSoundFirst){
        [self previewSonic];
    }
}

- (void) audioRecordStartedForManager:(SonicraphMediaManager *)manager
{
    if(self.recordType == SonicRecordTypePhotoFirst){
        [self.activityIndicator stopAnimating];
        [self.recordButton addTarget:self action:@selector(stopAudioRecording) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setImage:[UIImage imageNamed:@"Sound Button.png"] forState:UIControlStateNormal];
    }
}

- (void) startAudioRecording
{
    [self.mediaManager startAuidoRecording];
    self.soundTimerInitialFireDate = [NSDate date];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSoundTimer:) userInfo:nil repeats:YES];
    if(self.recordType == SonicRecordTypeSoundFirst){
        [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) updateSoundTimer:(NSTimer*) timer
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.soundTimerInitialFireDate];
    if(interval < MaximumSoundInterval){
        self.soundTimeSlider.value = self.mediaManager.audioRecorder.currentTime;
    }
    else {
        [self.soundTimer invalidate];
        if (self.recordType == SonicRecordTypePhotoFirst) {
            [self stopAudioRecording];
        }
        else if(self.recordType == SonicRecordTypeSoundFirst){
            [self takePicture];
        }
    }
}

- (void) stopAudioRecording
{
    [self.soundTimer invalidate];
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

    [self.flashButton setImage:[UIImage imageNamed:@"Camera Flash.png"] forState:UIControlStateNormal];

    [self.flashButton setFrame:[self flashButtonFrame]];
    [self.cameraFeaturesBar addSubview:self.flashButton];
    
    self.recordTypeSwitch = [[UISegmentedControl alloc] initWithFrame:[self recordTypeSwitchFrame]];
    [self.cameraFeaturesBar addSubview:self.recordTypeSwitch];
    [self.recordTypeSwitch addTarget:self action:@selector(recordTypeSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self.recordTypeSwitch insertSegmentWithTitle:@"Sound First" atIndex:0 animated:NO];
    [self.recordTypeSwitch insertSegmentWithTitle:@"Photo First" atIndex:1 animated:NO];
    [self.recordTypeSwitch setTintColor:[UIColor whiteColor]];
    
    self.cameraTypeToggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cameraTypeToggleButton.frame = [self cameraTypeToggleButtonFrame];
    [self.cameraTypeToggleButton setImage:[UIImage imageNamed:@"CameraBackFrontWhite.png"] forState:UIControlStateNormal];
    [self.cameraTypeToggleButton addTarget:self action:@selector(toggleCameraType) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraTypeToggleButton setTintColor:[UIColor whiteColor]];
    [self.cameraFeaturesBar addSubview:self.cameraTypeToggleButton];

}

- (void) toggleCameraType
{
    if (isMainCamera){
        [self.mediaManager useFrontCamera];
        isMainCamera = NO;
    } else {
        [self.mediaManager useMainCamera];
        isMainCamera = YES;
    }
}

- (void) recordTypeSwitchChanged
{
    if(self.recordTypeSwitch.selectedSegmentIndex == 0){
        self.recordType = SonicRecordTypeSoundFirst;
        [self.recordButton setImage:RecordButtonMicrophoneImage forState:UIControlStateNormal];
    }
    else {
        self.recordType = SonicRecordTypePhotoFirst;
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
    }
}

- (void) initializeSoundTimeSlider
{
    self.soundTimeSlider = [[SNCSoundSlider alloc] init];
    [self.soundTimeSlider setFrame:[self soundTimeSliderFrame]];
    [self.soundTimeSlider setMinimumValue:0.0];
    [self.soundTimeSlider setMaximumValue:SonicSoundMaxTime];
    [self.soundTimeSlider setFillColor:[UIColor redColor]];
    [self.soundTimeSlider setBaseColor:[UIColor darkGrayColor]];
    [self.view addSubview:self.soundTimeSlider];
    
}

- (void) initializeCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setFrame:[self cancelButtonFrame]];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTintColor:[UIColor whiteColor]];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
}

- (void) cancelButtonTapped
{
    capturedAudio = nil;
    capturedImage = nil;
    [self.soundTimer invalidate];
    [self.mediaManager stopAudioRecording];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[SNCTabbarController sharedInstance] openPreviousTab];

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
    isMainCamera = YES;
}

-(void)manager:(SonicraphMediaManager *)manager audioDataReady:(NSData *)data
{
    capturedAudio = data;
//    NSLog(@"%@",data);
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
    if([segue.destinationViewController isKindOfClass:[SNCEditViewController class]]){
        SonicData* sonic = [[SonicData alloc] initWithImage:capturedImage andSound:nil];
        [sonic setRawSound:capturedAudio];
        SNCEditViewController* previewController = segue.destinationViewController;
        [previewController setSonic:sonic];
        capturedAudio = nil;
        capturedImage = nil;
        tapIndex = 0;
    }
}

@end
