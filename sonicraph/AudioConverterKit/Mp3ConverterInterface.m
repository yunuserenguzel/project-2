//
//  Mp3ConverterInterface.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/4/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Mp3ConverterInterface.h"

@interface Mp3ConverterInterface ()


@end

static Mp3ConverterInterface* sharedInstance = nil;

@implementation Mp3ConverterInterface
{
    Block completionBlock;
    NSURL* inputFile;
    NSString* outputFileName;
    CGFloat start;
    CGFloat length;
}

- (id)init
{
    if(self = [super init]){
        start = -1;
        length = -1;
    }
    return self;
}
//+ (Mp3ConverterInterface *)sharedInstance
//{
//    if(sharedInstance == nil){
//        sharedInstance = [[Mp3ConverterInterface alloc] init];
//    }
//    return sharedInstance;
//}
- (void)convertMp3FromFile:(NSURL *)from toOutputName:(NSString *)_outputName andCompletionBlock:(Block)_completionBlock;

{
    outputFileName = _outputName;
    completionBlock = _completionBlock;
    inputFile = from;
    [self startConvertion];
}

- (void) convertMp3FromFile:(NSURL*)from toOutputName:(NSString *)outputName withStarting:(CGFloat)_start andLength:(CGFloat)_length andCompletionBlock:(Block)_completionBlock;
{
    completionBlock = _completionBlock;
    inputFile = from;
    outputFileName = outputName;
    start = _start;
    length = _length;
    if(length < 0 || start < 0 || start >= length){
        @throw [NSException exceptionWithName:@"InvalidInput" reason:@"start and length should greater than zero and start must be smaller then length" userInfo:nil];
    }
    [self startConvertion];
}

- (void) startConvertion
{
    NSString* outputFile = [[inputFile URLByDeletingLastPathComponent].path stringByAppendingPathComponent:outputFileName];
    NSLog(@"Mp3ConverterInterface outputFile: %@",outputFile);
    [@"" writeToFile:outputFile atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MP3Converter *mp3Converter = [[MP3Converter alloc] initWithPreset:PRESET_PHONE];
    mp3Converter.delegate = self;
    [mp3Converter initializeLame];
    if(start > 0){
        [mp3Converter setConversionStartPoint:start];
    }
    if(length > 0){
        [mp3Converter setConversionLength:length];
    }
    mp3Converter.bitrate = 128;
    mp3Converter.vbrQuality = LOW_QUALITY;
    mp3Converter.encodingEngineQuality = Fast;
    [mp3Converter convertMP3WithFilePath:inputFile.path outputName:outputFileName];
}

- (void)convertDone:(MP3Converter *)converter
{
    if(completionBlock != nil){
        completionBlock();
    }
}

- (void)convertFailed:(MP3Converter *)converter
{
    NSLog(@"Mp3ConvertedInterface: mp3convertion is failed! ");
}

@end
