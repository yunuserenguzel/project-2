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

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, src.size.width, src.size.height), src.CGImage);
    
    if (orientation == UIImageOrientationRight)
    {
        CGContextRotateCTM (context, radians(90));
    }
    else if (orientation == UIImageOrientationLeft)
    {
        CGContextRotateCTM (context, radians(-90));
    }
    else if (orientation == UIImageOrientationDown)
    {
        // NOTHING
    }
    else if (orientation == UIImageOrientationUp)
    {
        CGContextRotateCTM (context, radians(90));
    }
    UIGraphicsEndImageContext();
    return UIGraphicsGetImageFromCurrentImageContext();
}

#define RecordButtonCameraImage [UIImage imageNamed:@"CaptureButtonCamera.png"]
#define RecordButtonMicrophoneImage [UIImage imageNamed:@"CaptureButtonMic.png"]

typedef enum SonicRecordType {
    SonicRecordTypePhotoFirst,
    SonicRecordTypeSoundFirst
} SonicRecordType;

#define DefaultSonicRecordType SonicRecordTypePhotoFirst

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

@property UIButton* retakeButton;

@end

@implementation SNCCameraViewController
{
    NSInteger tapIndex;
    UIImage* capturedImage;
    NSData* capturedAudio;
    BOOL isMainCamera;
    AVCaptureFlashMode flashMode;
    UIDeviceOrientation capturedImageOrientation;
    
    CLLocationManager* locationManager;
    CLLocation *currentLocation;
    BOOL isMediaManagerReady;
}

-(CGRect) flashButtonFrame
{
    return CGRectMake(10.0, 10.0, 44.0, 44.0);
}

- (CGRect) cameraTypeToggleButtonFrame
{
    return CGRectMake(self.view.frame.size.width - 54.0, 10.0, 44.0, 44.0);
}

- (CGRect) recordTypeSwitchFrame
{
    return CGRectMake(80.0, 20.0, 160.0, 26.0);
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
    return CGRectMake(self.view.frame.size.width*0.5 - 50.0, self.view.frame.size.height-130.0, 99.0, 99.0);
}

-(CGRect) soundTimeSliderFrame
{
    return CGRectMake(0.0, 387.0, 320.0, 3.0);
}

-(CGRect) cancelButtonFrame
{
    return CGRectMake(320.0-80.0, self.view.frame.size.height-100.0, 66.0, 66.0);
}

- (CGRect) retakeButtonFrame
{
    return CGRectMake(14.0, self.view.frame.size.height-100.0, 66.0, 66.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isMediaManagerReady = NO;
    self.recordType = DefaultSonicRecordType;
    [self.view setBackgroundColor:CameraViewControllersBackgroundColor];
    self.cameraView = [[UIView alloc] initWithFrame:[self cameraViewFrame]];
    [self.view addSubview:self.cameraView];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusForTap:)];
    [self.cameraView addGestureRecognizer:tapGesture];
    
    [self initializeMaskView];
    [self initializeCameraFeaturesBar];
    [self initializeSoundTimeSlider];
    [self initializeRetakeAndCancelButton];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
    [self.recordButton setFrame:[self recordButtonFrame]];
    [self.recordButton setEnabled:NO];
    [self.view addSubview:self.recordButton];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [[[NSThread alloc]
      initWithTarget:self
      selector:@selector(initializeMediaManager)
      object:nil]
     start];
    
}

- (CGFloat) angleWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    CGFloat angle;
    switch (deviceOrientation)
	{
		case UIDeviceOrientationPortrait:
			angle = 0.0f; break;
		case UIDeviceOrientationPortraitUpsideDown:
			angle =  M_PI; break;
		case UIDeviceOrientationLandscapeLeft:
			angle =  (M_PI/2.0f); break;
		case UIDeviceOrientationLandscapeRight:
			angle =  -(M_PI/2.0f); break;
		default:
			angle = 0.0f;
	}
    return angle;
}

- (void) orientationChanged:(NSNotification*)notification
{
    UIDevice* device = notification.object;
    CGFloat angle = [self angleWithDeviceOrientation:device.orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    [UIView animateWithDuration:0.3 animations:^{
        self.retakeButton.transform = transform;
        self.recordButton.transform = transform;
        self.cancelButton.transform = transform;
        self.flashButton.transform = transform;
        self.cameraTypeToggleButton.transform = transform;
    }];
    if(device.orientation == UIDeviceOrientationLandscapeLeft)
    {
        [self.recordTypeSwitch setImage:[UIImage imageNamed:@"MiniCameraLeft.png"] forSegmentAtIndex:0];
        [self.recordTypeSwitch setImage:[UIImage imageNamed:@"MiniMicLeft.png"] forSegmentAtIndex:1];
    }
    else if(device.orientation == UIDeviceOrientationLandscapeRight)
    {
        [self.recordTypeSwitch setImage:[UIImage imageNamed:@"MiniCameraRight.png"] forSegmentAtIndex:0];
        [self.recordTypeSwitch setImage:[UIImage imageNamed:@"MiniMicRight.png"] forSegmentAtIndex:1];
    }
    else
    {
        [self.recordTypeSwitch setTitle:@"Photo First" forSegmentAtIndex:0];
        [self.recordTypeSwitch setTitle:@"Sound First" forSegmentAtIndex:1];
    }
}

- (void) focusForTap:(UITapGestureRecognizer*)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.cameraView];
    if (CGRectContainsPoint([self visibleRectFrame], point))
    {
        CGFloat size = 15.0;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(point.x - size, point.y - size, size * 2, size * 2)];
        imageView.alpha = 0.0;
        [imageView setBackgroundColor:[UIColor whiteColor]];
        [imageView.layer setCornerRadius:size];
        [imageView.layer setShadowColor:[UIColor whiteColor].CGColor];
        [imageView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
        [imageView.layer setShadowRadius:size];
        [imageView.layer setShadowOpacity:1.0];
        [self.maskView addSubview:imageView];
        
        NSLog(@"start of focus");
        CGPoint pointOfInterest = CGPointMake(point.y / [self cameraViewFrame].size.height, ([self cameraViewFrame].size.width-point.x) / [self cameraViewFrame].size.width);
        [self.mediaManager focusCameraToPoint:pointOfInterest withCompletionBlock:^{
            NSLog(@"end of focus");
        }];
        [UIView animateWithDuration:0.2 animations:^{
            imageView.alpha = 1.0;
            imageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                imageView.alpha = 0.0;
                imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        }];
    }
}

- (void) recordButtonPressed
{
    [self.recordTypeSwitch setEnabled:NO];
    if(self.recordType == SonicRecordTypeSoundFirst)
    {
        [self startAudioRecording];
    }
    else
    {
        [self takePicture];
    }
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) previewSonic
{
    if(capturedImage != nil && capturedAudio != nil)
    {
        [self performSegueWithIdentifier:EditSonicSegue sender:self];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.recordTypeSwitch setSelectedSegmentIndex:0];
    if(isMediaManagerReady)
    {
        [self.recordButton setEnabled:YES];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.mediaManager startCamera];

    [self.recordTypeSwitch setEnabled:YES];
    [self.activityIndicator stopAnimating];
    [self.soundTimeSlider setValue:0.0];
    [self.recordButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if(self.recordType == SonicRecordTypeSoundFirst)
    {
        [self.recordButton setImage:RecordButtonMicrophoneImage forState:UIControlStateNormal];
    }
    else
    {
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
    }
    
    [locationManager startUpdatingLocation];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [self.soundTimer invalidate];
    [locationManager stopUpdatingLocation];
}

- (void) takePicture
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
    [self.maskView addSubview:self.activityIndicator];
    [self.activityIndicator setFrame:CGRectMake(0.0, 0.0, self.maskView.frame.size.width, self.maskView.frame.size.height)];
    [self.activityIndicator startAnimating];
    [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    capturedImageOrientation = [[UIDevice currentDevice] orientation];
    [self.view setUserInteractionEnabled:NO];
    ImageBlock block = ^(UIImage *image) {
        [self performSelector:@selector(formatCapturedImage:) withObject:image afterDelay:0.0];
        if(self.recordType == SonicRecordTypePhotoFirst)
        {
            [self startAudioRecording];
        }
        if(self.recordType == SonicRecordTypeSoundFirst)
        {
            [self stopAudioRecording];
        }
        [self.view setUserInteractionEnabled:YES];
    };
    [self.mediaManager performSelector:@selector(takePictureWithCompletionBlock:) withObject:block afterDelay:0.0];
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
    if(capturedImageOrientation == UIDeviceOrientationLandscapeLeft)
    {
        capturedImage = [self image:capturedImage rotate:UIImageOrientationLeft];
    }
    else if (capturedImageOrientation == UIDeviceOrientationLandscapeRight)
    {
        capturedImage = [self image:capturedImage rotate:UIImageOrientationRight];
    }
    else if (capturedImageOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        capturedImage = [self image:capturedImage rotate:UIImageOrientationDown];
    }
    if(self.recordType == SonicRecordTypeSoundFirst)
    {
        [self previewSonic];
    }
}

- (void) audioRecordStartedForManager:(SonicraphMediaManager *)manager
{
    if(self.recordType == SonicRecordTypePhotoFirst)
    {
        [self.activityIndicator stopAnimating];
        [self.recordButton addTarget:self action:@selector(stopAudioRecording) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setImage:RecordButtonMicrophoneImage forState:UIControlStateNormal];
    }
}

- (void) startAudioRecording
{
    [self.mediaManager startAuidoRecording];
    [self.recordButton setEnabled:NO];
    self.soundTimerInitialFireDate = [NSDate date];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSoundTimer:) userInfo:nil repeats:YES];
    if(self.recordType == SonicRecordTypeSoundFirst)
    {
        [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) updateSoundTimer:(NSTimer*) timer
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.soundTimerInitialFireDate];
    if(interval < SonicMinimumSoundInterval)
    {
        [self.recordButton setEnabled:NO];
    }
    else
    {
        [self.recordButton setEnabled:YES];
    }
    if(interval < SonicMaximumSoundInterval)
    {
        self.soundTimeSlider.value = self.mediaManager.audioRecorder.currentTime;
    }
    else
    {
        [self.soundTimer invalidate];
        if (self.recordType == SonicRecordTypePhotoFirst)
        {
            [self stopAudioRecording];
        }
        else if(self.recordType == SonicRecordTypeSoundFirst)
        {
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
    [self.flashButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [self.flashButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [self.flashButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.flashButton setTitle:@"Off" forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"GleamWhite.png"] forState:UIControlStateNormal];
    [self.flashButton setFrame:[self flashButtonFrame]];
    [self.flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraFeaturesBar addSubview:self.flashButton];
    [self toggleFlash];
    
    self.recordTypeSwitch = [[UISegmentedControl alloc] initWithFrame:[self recordTypeSwitchFrame]];
    [self.cameraFeaturesBar addSubview:self.recordTypeSwitch];
    [self.recordTypeSwitch addTarget:self action:@selector(recordTypeSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self.recordTypeSwitch insertSegmentWithTitle:@"Photo First" atIndex:0 animated:NO];
    [self.recordTypeSwitch insertSegmentWithTitle:@"Sound First" atIndex:1 animated:NO];
    [self.recordTypeSwitch setTintColor:[UIColor whiteColor]];

    self.cameraTypeToggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cameraTypeToggleButton.frame = [self cameraTypeToggleButtonFrame];
    [self.cameraTypeToggleButton setImage:[UIImage imageNamed:@"CameraFrontBackWhite.png"] forState:UIControlStateNormal];
    [self.cameraTypeToggleButton addTarget:self action:@selector(toggleCameraType) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraTypeToggleButton setTintColor:[UIColor whiteColor]];
    [self.cameraFeaturesBar addSubview:self.cameraTypeToggleButton];
}

- (void) toggleCameraType
{
    if (isMainCamera)
    {
        [self.mediaManager useFrontCamera];
        isMainCamera = NO;
    }
    else
    {
        [self.mediaManager useMainCamera];
        isMainCamera = YES;
    }
}

- (void) toggleFlash
{
    AVCaptureFlashMode requestedFlashMode;
    if (flashMode == AVCaptureFlashModeOff)
    {
        NSLog(@"requestedFlashMode is AvCaptureFlashModeAuto");
        requestedFlashMode = AVCaptureFlashModeAuto;
    }
    else if (flashMode == AVCaptureFlashModeAuto)
    {
        NSLog(@"requestedFlashMode is AvCaptureFlashModeOn");
        requestedFlashMode = AVCaptureFlashModeOn;
    }
    else
    {
        NSLog(@"requestedFlashMode is AvCaptureFlashModeOff");
        requestedFlashMode = AVCaptureFlashModeOff;
    }
    if([self.mediaManager setFlashMode:requestedFlashMode])
    {
        NSLog(@"requestedflashmode granted");
        flashMode = requestedFlashMode;
        if(flashMode == AVCaptureFlashModeAuto)
        {
            [self.flashButton setTitle:@"Auto" forState:UIControlStateNormal];
        }
        else if(flashMode == AVCaptureFlashModeOn)
        {
            [self.flashButton setTitle:@"On" forState:UIControlStateNormal];
        }
        else if(flashMode == AVCaptureFlashModeOff)
        {
            [self.flashButton setTitle:@"Off" forState:UIControlStateNormal];
        }
    }
    else
    {
        NSLog(@"flash mode is not supported");
    }
}

- (void) recordTypeSwitchChanged
{
    if(self.recordTypeSwitch.selectedSegmentIndex == 1)
    {
        self.recordType = SonicRecordTypeSoundFirst;
        [self.recordButton setImage:RecordButtonMicrophoneImage forState:UIControlStateNormal];
    }
    else
    {
        self.recordType = SonicRecordTypePhotoFirst;
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
    }
}

- (void) initializeSoundTimeSlider
{
    self.soundTimeSlider = [[SNCSoundSlider alloc] init];
    [self.soundTimeSlider setFrame:[self soundTimeSliderFrame]];
    [self.soundTimeSlider setMinimumValue:0.0];
    [self.soundTimeSlider setMaximumValue:SonicMaximumSoundInterval];
    [self.soundTimeSlider setFillColor:PinkColor];
    [self.soundTimeSlider setBaseColor:[UIColor whiteColor]];
    [self.view addSubview:self.soundTimeSlider];
}

- (void) initializeRetakeAndCancelButton
{
    self.retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retakeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [self.retakeButton setFrame:[self retakeButtonFrame]];
    [self.retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
    [self.retakeButton setTintColor:[UIColor whiteColor]];
    [self.retakeButton addTarget:self action:@selector(prepareForRetake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.retakeButton];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
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
- (void) prepareForRetake
{
    capturedAudio = nil;
    capturedImage = nil;
    [self.soundTimer invalidate];
    [self.mediaManager stopAudioRecording];
    [self.recordButton setEnabled:YES];
    [self.mediaManager startCamera];
    [self.recordTypeSwitch setEnabled:YES];
    [self.activityIndicator stopAnimating];
    [self.soundTimeSlider setValue:0.0];
    if(self.recordType == SonicRecordTypeSoundFirst)
    {
        [self.recordButton setImage:RecordButtonMicrophoneImage forState:UIControlStateNormal];
    }
    else
    {
        [self.recordButton setImage:RecordButtonCameraImage forState:UIControlStateNormal];
    }
    [self.recordButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) initializeMediaManager
{
    self.mediaManager = [[SonicraphMediaManager alloc] initWithView:self.cameraView];
    [self.mediaManager setDelegate:self];
    isMainCamera = YES;
    isMediaManagerReady = YES;
    [self.recordButton setEnabled:YES];
    NSLog(@"Media Manager Ready");
}

-(void)manager:(SonicraphMediaManager *)manager audioDataReady:(NSData *)data
{
    capturedAudio = data;
    [self previewSonic];
}

- (void) initializeMaskView
{
    self.maskView = [UIImageView new];
    [self.maskView setFrame:[self cameraViewFrame]];
    [self.maskView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.maskView];
    
    UIGraphicsBeginImageContextWithOptions(self.maskView.frame.size, NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetFillColorWithColor(context, CameraViewControllersBackgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, self.maskView.frame.size.width, self.maskView.frame.size.height));
    CGContextClearRect(context, [self visibleRectFrame]);
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.maskView setImage:maskImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[SNCEditViewController class]])
    {
        SonicData* sonic = [[SonicData alloc] initWithImage:capturedImage andSound:nil];
        [sonic setRawSound:capturedAudio];
        sonic.latitude = currentLocation.coordinate.latitude;
        sonic.longitude = currentLocation.coordinate.longitude;
        SNCEditViewController* previewController = segue.destinationViewController;
        [previewController setSonic:sonic];
        capturedAudio = nil;
        capturedImage = nil;
        tapIndex = 0;
    }
}

// Failed to get current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//							   initWithTitle:@"Error"
//                               message:@"Failed to Get Your Location"
//                               delegate:nil
//                               cancelButtonTitle:@"OK"
//                               otherButtonTitles:nil];
//    // Call alert
//	[errorAlert show];
}

// Got location and now update
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
	NSLog(@"%@", currentLocation);
}

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

-(UIImage*)image:(UIImage*)image rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = image.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return image;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}
@end
