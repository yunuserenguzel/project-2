//
//  Sonickle.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"
#import <AVFoundation/AVFoundation.h>

@implementation Sonic

+ (Sonic*) sonickleFromDictionary:(NSDictionary*)dictionary
{
    UIImage* image = [UIImage imageWithData:[dictionary objectForKey:@"image"]];
    return [Sonic sonickleWithImage:image andSound:[dictionary objectForKey:@"sound"] withId:[dictionary objectForKey:@"sonickleId"]];
}

- (NSDictionary*)dictionaryFromSonickle
{
    NSData* imageData = UIImageJPEGRepresentation(self.image, 1.0);
    return @{ @"image": imageData, @"sound": self.sound, @"sonickleId": self.sonicId };
}

+ (Sonic *)sonickleWithImage:(UIImage *)image andSound:(NSData *)sound withId:(NSString *)sonickleId
{
    return [[Sonic alloc] initWithImage:image andSound:sound withId:sonickleId];
}


+ (Sonic *)readFromFile:(NSString *)fileName
{
    return nil;
}

- (id)initWithImage:(UIImage *)image andSound:(NSData *)sound withId:(NSString *)sonickleId
{
    if(self = [super init]){
        _image = image;
        _sound = sound;
        _sonicId = sonickleId;
    }
    return self;
}

- (NSString*) documents
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

- (void)saveToFile
{
    NSString* fileName = [self documents];
    fileName = [fileName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.snc",self.sonicId]];

    
    NSMutableArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:SonicklesUserDefaultsKey];
    if(array == nil){
        array = [[NSMutableArray alloc] init];
    }
    [array addObject:fileName];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:SonicklesUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary* file = [self dictionaryFromSonickle];
    [file writeToFile:fileName atomically:YES];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//    long long fileSize = [fileSizeNumber longLongValue];
    
    NSLog(@"fileName: %@\nfileSize: %@",fileName,fileSizeNumber);
}


- (void)sonicFromCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock
{
    float vocalStartMarker = from;
    float vocalEndMarker = to;
    
    NSURL *audioFileInput = [NSURL fileURLWithPath:[[self documents] stringByAppendingPathComponent:@"inputAudio"]];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:[[self documents] stringByAppendingPathComponent:@"outputAudio"]];
    
    NSLog(@"%@",self.sound);
    NSError* error;
    [self.sound writeToURL:audioFileInput options:NSDataWritingFileProtectionComplete error:&error];
    NSLog(@"error: %@, file: %@",error,[NSData dataWithContentsOfURL:audioFileInput]);
    if (!audioFileInput || !audioFileOutput)
    {
        sonicBlock(nil,[[NSError alloc] init]);
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        sonicBlock(nil, [[NSError alloc] init]);
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             //create sonic from file
             NSData* soundData = [NSData dataWithContentsOfURL:audioFileOutput];
             Sonic* sonic = [[Sonic alloc] initWithImage:self.image andSound:soundData withId:self.sonicId];
             sonicBlock(sonic,nil);
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
             sonicBlock(nil, exportSession.error);
         }
     }];
    

}

@end
