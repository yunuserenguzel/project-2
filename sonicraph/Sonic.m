//
//  Sonickle.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"
#import <AVFoundation/AVFoundation.h>
#import "Mp3ConverterInterface.h"
@implementation Sonic
{
    Mp3ConverterInterface* mp3ConverterInterface;
}
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


- (void)setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock
{
    if(self.rawSound == nil){
        NSLog(@"setSoundCroppingFrom method requires rawSound to be set");
        return;
    }
    NSURL *audioFileInput = [NSURL fileURLWithPath:[[self documents] stringByAppendingPathComponent:@"sonicConvertInputAudio.aac"]];
    NSString* outputName = @"sonicConvertOuputAuido.mp3";
    NSError* error;
    
    [self.rawSound writeToFile:audioFileInput.path options:NSDataWritingAtomic error:&error];
    if(error){
        NSLog(@"sonicFromCroppingFrom error: %@",error);
    }
    
    mp3ConverterInterface = [[Mp3ConverterInterface alloc] init];
    [mp3ConverterInterface convertMp3FromFile:audioFileInput toOutputName:outputName withStarting:from andLength:to-from andCompletionBlock:^{
        NSData* soundData = [NSData dataWithContentsOfURL:[[audioFileInput URLByDeletingLastPathComponent] URLByAppendingPathComponent:outputName]];
        self.sound = soundData;
        self.start =  from;
        self.length = to-from;
        sonicBlock(self,nil);
    }];
}

@end
