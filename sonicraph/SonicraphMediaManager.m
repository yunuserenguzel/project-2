//
//  SonicMediaManager.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 9/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicraphMediaManager.h"

#define TempSoundFileName @"sound.caf"
#define TempConvertedSoundFileName @"converted_sound.caf"

/*
 http://www.tekritisoftware.com/convert-caf-to-mp3-in-iOS
 http://lame.sourceforge.net/
 */

@implementation SonicraphMediaManager
{
    AVCaptureSession* session;
    AVCaptureDevice* device;
    AVCaptureStillImageOutput* stillImageOutput;
    AVAudioRecorder *audioRecorder;
    
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
        [self initializeCamera];
        [self initializeAudio];
    }
    return self;
}
- (void) initializeCamera
{
    
    session = [[AVCaptureSession alloc] init];
    device = [[AVCaptureDevice devices] objectAtIndex:0];
    
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    
    if ([session canAddInput:captureDeviceInput]) {
        [session addInput:captureDeviceInput];
    }
    else {
        // Handle the failure.
    }
    
//    AVCaptureDeviceInput* audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[[AVCaptureDevice devices] objectAtIndex:2] error:nil];
//    if ([session canAddInput:audioInput]) {
//        [session addInput:audioInput];
//    }
//    else {
//        // Handle the failure.
//    }
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
            
            audioRecorder = [[AVAudioRecorder alloc]
                             initWithURL:[self tempSoundFileUrl]
                             settings:recordSettings
                             error:&error];
            audioRecorder.delegate = self;
            if (error)
            {
                NSLog(@"error: %@", [error localizedDescription]);
                
            } else {
                [audioRecorder prepareToRecord];
            }

        }
        else {
            // Microphone disabled code
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
//             image = [image imageByScalingAndCroppingForSize:CGSizeMake(612.0, 612.0)];
//             image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.6)];
             completionBlock(image);
             
//             NSLog(@"w:%f, h:%f",image.size.width,image.size.height);
//             NSLog(@"input file: %@ outputfile:%@",[self tempSoundFileUrl].path,[self tempConvertedSoundFileUrl].path);
             
         }
     }];
    
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
    if(!audioRecorder.isRecording){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:NULL];
        if([audioRecorder record]){
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
    if(audioRecorder.isRecording){
        [audioRecorder stop];
//        mp3ConverterInterface = [[Mp3ConverterInterface alloc] init];
//        [mp3ConverterInterface convertMp3FromFile:[self tempSoundFileUrl] toOutputName:TempConvertedSoundFileName andCompletionBlock:^{
//            NSLog(@"SonicMediaManager: auido convert is done");
//            NSData* soundData = [NSData dataWithContentsOfURL:[self tempConvertedSoundFileUrl]];
//            NSLog(@"soundData: %d",soundData.length);
//            [self.delegate manager:self audioDataReady:soundData];
//        }];
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
