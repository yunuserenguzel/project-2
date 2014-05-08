//
//  SonicMediaManager.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 9/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicraphMediaManager.h"
#import "UIImage+scaleToSize.h"
#import "UIImage+imageForSoundData.h"

#define TempSoundFileName @"sound.caf"
#define TempConvertedSoundFileName @"converted_sound.caf"

/*
 http://www.tekritisoftware.com/convert-caf-to-mp3-in-iOS
 http://lame.sourceforge.net/
 */

@implementation SonicraphMediaManager
{
    AVCaptureSession* session;
    
    
    AVCaptureStillImageOutput* stillImageOutput;
    
    AVCaptureDeviceInput* currentDeviceInput;
    AVCaptureDeviceInput* backCameraInput;
    AVCaptureDeviceInput* frontCameraInput;
    
    Mp3ConverterInterface* mp3ConverterInterface;
    
    CFURLRef sourceURL;
    CFURLRef destinationURL;
    OSType   outputFormat;
    Float64  sampleRate;
    UIImage* image;

}
- (id)initWithView:(UIView *)view
{
    if(self = [super init]){
        _cameraView = view;
    }
    return self;
}

- (void) prepareForCapture
{
    [self initializeCamera];
    [self initializeAudio];
}
- (void) initializeCamera
{
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [self useMainCamera];
    
    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [layer setFrame:CGRectMake(0.0, 0.0, self.cameraView.frame.size.width, self.cameraView.frame.size.height)];
    
    [self.cameraView.layer addSublayer:layer];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:stillImageOutput];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session startRunning];
    
    
}

- (void) initializeAudio
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSDictionary *recordSettings = [NSDictionary
                                            dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:AVAudioQualityHigh],
                                            AVEncoderAudioQualityKey,
                                            [NSNumber numberWithInt:64],
                                            AVEncoderBitRateKey,
                                            [NSNumber numberWithInt: 2],
                                            AVNumberOfChannelsKey,
                                            [NSNumber numberWithFloat:44100.0],
                                            AVSampleRateKey,
                                            nil];
            
            NSError *error = nil;
            
            _audioRecorder = [[AVAudioRecorder alloc]
                             initWithURL:[self tempSoundFileUrl]
                             settings:recordSettings
                             error:&error];
            self.audioRecorder.delegate = self;
            if (error)
            {
                NSLog(@"error: %@", [error localizedDescription]);
                
            } else {
                [self.audioRecorder prepareToRecord];
                if([self.delegate respondsToSelector:@selector(sonicraphMediaManagerReady:)])
                {
                    [self.delegate sonicraphMediaManagerReady:self];
                }
            }
        }
        else {
            if([self.delegate respondsToSelector:@selector(microphonePermissionDeniedForManager:)])
            {
                [self.delegate microphonePermissionDeniedForManager:self];
            }
        }
    }];
}

- (void)takePictureWithCompletionBlock:(ImageBlock)completionBlock
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqualToString:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if(error == nil){
             [session stopRunning];
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             image = [UIImage imageWithData:imageData];
             completionBlock(image);
         }
     }];
    
}

- (void)useFrontCamera
{
    [session removeInput:backCameraInput];
    backCameraInput = nil;
    AVCaptureDevice* device = [AVCaptureDevice deviceWithUniqueID:@"com.apple.avfoundation.avcapturedevice.built-in_video:1"];
    currentDeviceInput = frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    if([session canAddInput:frontCameraInput]){
        [session addInput:frontCameraInput];
    }
}

- (void)useMainCamera
{
    [session removeInput:frontCameraInput];
    frontCameraInput = nil;
    AVCaptureDevice* device = [AVCaptureDevice deviceWithUniqueID:@"com.apple.avfoundation.avcapturedevice.built-in_video:0"];
    currentDeviceInput = backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    if ([session canAddInput:backCameraInput]) {
        [session addInput:backCameraInput];
    }
    else {
        // Handle the failure.
    }
}

- (void)focusCameraToPoint:(CGPoint)point withCompletionBlock:(void (^)())completionBlock
{
    NSLog(@"focus point: %f, %f", point.x,point.y);
    AVCaptureDevice* device = currentDeviceInput.device;
    if(device){
        NSError* error;
        if([device lockForConfiguration:&error]){
            if([device isFocusPointOfInterestSupported]){
                [device setFocusPointOfInterest:point];
            } else {
                NSLog(@"device focus point of interest is not supported");
            }
            if([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
            } else {
                NSLog(@"device auto focus mode is not supported");
            }
            if([device isExposurePointOfInterestSupported]){
                [device setExposurePointOfInterest:point];
            } else {
                
            }
            if([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            } else if([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            } else {
                NSLog(@"device auto exposure and contonous auto exposure are not supported");
            }
            [device unlockForConfiguration];
        }
        if(error){
            NSLog(@"error for focus on camera : %@",error);
        }
    }
    if(completionBlock){
        completionBlock();
    }
}
- (BOOL) setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice* device = currentDeviceInput.device;
    if(device){
        if([device isFlashAvailable]){
            if([device isFlashModeSupported:flashMode]){
                if([device lockForConfiguration:nil]){
                    [device setFlashMode:flashMode];
                    return true;
                }
            }
        }
    }
    return false;
}

- (void) startCamera
{
    if([session isRunning] == NO){
        [[[NSThread alloc] initWithTarget:session selector:@selector(startRunning) object:nil] start];
//    [session startRunning];
    }
}

- (void) stopCamera
{
    [session stopRunning];
}

- (void) startAuidoRecording
{
    if(!self.audioRecorder.isRecording){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:NULL];
        if([self.audioRecorder record]){
            NSLog(@"Audio recording is started");
            [self.delegate audioRecordStartedForManager:self];
        }
        else {
            NSLog(@"Auido recording is failed to start");
        }
    }
}

- (void) stopAudioRecording
{
    NSLog(@"SonicMediaManager: stopping auido record");
    if(self.audioRecorder.isRecording){
        [self.audioRecorder stop];
        NSData* soundData = [NSData dataWithContentsOfURL:[self tempSoundFileUrl]];
        [self.delegate manager:self audioDataReady:soundData];
    }
    else {
        NSLog(@"Audio recorder is not recording!!!");
    }
}

//- (void)convertFailed:(MP3Converter *)converter
//{
////    NSLog(@"")
//}
//
//- (void)convertDone:(MP3Converter *)converter
//{
//    NSLog(@"SonicMediaManager: auido convert is done");
//    NSData* soundData = [NSData dataWithContentsOfURL:[self tempConvertedSoundFileUrl]];
//    NSLog(@"soundData: %d",soundData.length);
//    [self.delegate manager:self audioDataReady:soundData];
//    
//}
- (NSURL*) tempConvertedSoundFileUrl
{
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:TempConvertedSoundFileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    return soundFileURL;
}

- (NSURL*) tempSoundFileUrl
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:TempSoundFileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    return soundFileURL;
}



-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}
-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}
-(void)audioRecorderDidFinishRecording:
(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag

{
    
    NSLog(@"record finish %d",flag);
}
-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}


@end
