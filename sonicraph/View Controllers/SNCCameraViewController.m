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
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    UIGraphicsEndImageContext();
    return UIGraphicsGetImageFromCurrentImageContext();
}

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
    AVCaptureFlashMode flashMode;
    UIDeviceOrientation capturedImageOrientation;
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
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusForTap:)];
    [self.cameraView addGestureRecognizer:tapGesture];
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
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
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
    NSLog(@"%@",device);
    CGFloat angle = [self angleWithDeviceOrientation:device.orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    [UIView animateWithDuration:0.3 animations:^{
        self.recordButton.transform = transform;
        self.cancelButton.transform = transform;
        self.flashButton.transform = transform;
        self.cameraTypeToggleButton.transform = transform;
    }];
}


//        UIGraphicsBeginImageContext(CGSizeMake(60.0, 60.0));
//        // This one does not:
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGGradientRef gradient;
//        CGColorSpaceRef colorspace;
//        CGFloat locations[2] = { 0.0, 1.0};
//        NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor blueColor].CGColor];
//        colorspace = CGColorSpaceCreateDeviceRGB();
//        gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
//        CGPoint startPoint, endPoint;
//        CGFloat startRadius, endRadius;
//        startPoint.x = 180;
//        startPoint.y = 180;
//        endPoint.x = 180;
//        endPoint.y = 180;
//        startRadius = 0;
//        endRadius = 100;
//        CGContextDrawRadialGradient (ctx, gradient, startPoint, startRadius, endPoint, endRadius, 0);
//
//        // Show the whole thing:
//        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

- (void) focusForTap:(UITapGestureRecognizer*)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.cameraView];
    if (CGRectContainsPoint([self visibleRectFrame], point)) {
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
        CGPoint pointOfInterest = CGPointMake(point.y / [self cameraViewFrame].size.height, ([self cameraViewFrame].size.width-point.x) / [self cameraViewFrame].size.width ) ;
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
    [self.maskView addSubview:self.activityIndicator];
    [self.activityIndicator setFrame:CGRectMake(0.0, 0.0, self.recordButton.frame.size.width, self.recordButton.frame.size.height)];
    [self.activityIndicator startAnimating];
    [self.recordButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    capturedImageOrientation = [[UIDevice currentDevice] orientation];
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
//    capturedImage = [self image:capturedImage rotate:UIImageOrientationUp];
    if(capturedImageOrientation == UIDeviceOrientationLandscapeLeft){
//        capturedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
        capturedImage = [self image:capturedImage rotate:UIImageOrientationLeft];
    }
    else if (capturedImageOrientation == UIDeviceOrientationLandscapeRight){
//        capturedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation: UIImageOrientationRight];
        capturedImage = [self image:capturedImage rotate:UIImageOrientationRight];
    }
    else if (capturedImageOrientation == UIDeviceOrientationPortraitUpsideDown){
//        capturedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation: UIImageOrientationDown];
        capturedImage = [self image:capturedImage rotate:UIImageOrientationDown];
    }
    if(self.recordType == SonicRecordTypeSoundFirst){
        [self previewSonic];
    }
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
    [self.flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraFeaturesBar addSubview:self.flashButton];
    [self toggleFlash];
    
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

- (void) toggleFlash
{
    AVCaptureFlashMode requestedFlashMode;
    if (flashMode == AVCaptureFlashModeOff){
        NSLog(@"requestedFlashMode is AvCaptureFlashModeAuto");
        requestedFlashMode = AVCaptureFlashModeAuto;
    }
    else if (flashMode == AVCaptureFlashModeAuto){
        NSLog(@"requestedFlashMode is AvCaptureFlashModeOn");
        requestedFlashMode = AVCaptureFlashModeOn;
    }
    else {
        NSLog(@"requestedFlashMode is AvCaptureFlashModeOff");
        requestedFlashMode = AVCaptureFlashModeOff;
    }
    
    if([self.mediaManager setFlashMode:requestedFlashMode]){
        NSLog(@"requestedflashmode granted");
        flashMode = requestedFlashMode;
    } else {
        NSLog(@"flash mode is not supported");
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
    
    CGContextClearRect(context, [self visibleRectFrame]);
    
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
