//
//  Sonickle.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"

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


- (void)saveToFile
{
    NSString* fileName = NSHomeDirectory();
    fileName = [fileName stringByAppendingPathComponent:@"Documents"];
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


@end
