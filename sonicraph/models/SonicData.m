//
//  Sonickle.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicData.h"
#import <AVFoundation/AVFoundation.h>
#import "Mp3ConverterInterface.h"
#import "JSONKit.h"
#import "NSData+Base64.h"

@implementation SonicData
{
    Mp3ConverterInterface* mp3ConverterInterface;
}

//+ (Sonic *)sonicFromServerResponseDictionary:(NSDictionary *)dictionary
//{
////    NSString* string = [NSData dataWithContentsOfURL:[dictionary @"sonic_url"]];
//    NSURL* sonicUrl = [NSURL URLWithString:[dictionary objectForKey:@"sonic_url"]];
//    NSError* error = nil;
//    NSString* sonicDataString = [NSString stringWithContentsOfURL:sonicUrl encoding:NSUTF8StringEncoding error:&error];
//    if(error){
//        return nil;
//    }
//    return [Sonic sonicWithJsonDataString:sonicDataString];
//}

+ (SonicData *) sonicDataWithJsonDataString:(NSString *)jsonDataString
{
    NSDictionary* sonicDict = [jsonDataString objectFromJSONString];
    UIImage* image = [UIImage imageWithData:[NSData dataFromBase64String:[sonicDict objectForKey:@"image"]]];
    NSData* sound = [NSData dataFromBase64String:[sonicDict objectForKey:@"sound"]];
    SonicData* sonic = [[SonicData alloc] initWithImage:image andSound:sound];
    return sonic;
}                       

- (NSDictionary*)dictionaryFromSonicData
{
    NSData* imageData = UIImageJPEGRepresentation(self.image, 1.0);
    NSLog(@"imageSize w:%f h:%f",self.image.size.width,self.image.size.height);
    NSLog(@"imageData: %d",[imageData length]);
    NSString* imageDataString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"imageDataString: %d",[[imageDataString dataUsingEncoding:NSUTF8StringEncoding] length]);
    return @{ @"image": imageDataString, @"sound": [self.sound base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] };
}

+ (SonicData *)sonicDataWithImage:(UIImage *)image andSound:(NSData *)sound
{
    return [[SonicData alloc] initWithImage:image andSound:sound];
}

+ (SonicData *)sonicDataFromFile:(NSString *)filePath
{
    NSString* sonicDataString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [SonicData sonicDataWithJsonDataString:sonicDataString];
}
+ (SonicData *)sonicDataWithSonic:(Sonic *)sonic
{
    NSString* filePath = [SonicData filePathWithId:sonic.sonicId];
    NSString* sonicDataString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [SonicData sonicDataWithJsonDataString:sonicDataString];
}

- (id)initWithImage:(UIImage *)image andSound:(NSData *)sound
{
    if(self = [super init]){
        _image = image;
        _sound = sound;
    }
    return self;
}

+ (NSString*) filePathWithId:(NSString*)id
{
    NSString* folderPath = [[SonicData documents] stringByAppendingPathComponent:@"sonics"];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:folderPath
     withIntermediateDirectories:NO
     attributes:nil
     error:nil];
    NSString* filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.snc",id]];
    return filePath;
}

- (void)saveToFile
{
    NSString* filePath = [SonicData filePathWithId:self.sonic.sonicId];
    NSString* file = [[self dictionaryFromSonicData] JSONString];
    NSError* error;
    [file writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"saveToFile error: %@",error);
}

- (void)setSonic:(Sonic *)sonic
{
    _sonic = sonic;
    if(sonic.sonicData != self){
        sonic.sonicData = self;
    }
}

+ (NSString*) documents
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}


- (void)setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock
{
    if(self.rawSound == nil){
        NSLog(@"setSoundCroppingFrom method requires rawSound to be set");
        return;
    }
    NSURL *audioFileInput = [NSURL fileURLWithPath:[[SonicData documents] stringByAppendingPathComponent:@"sonicConvertInputAudio.aac"]];
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
