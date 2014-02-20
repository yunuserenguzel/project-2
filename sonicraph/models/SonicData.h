//
//  Sonickle.h
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+scaleToSize.h"
#import "Sonic.h"

@class SonicData;

typedef void (^SonicDataBlock) (SonicData* sonicData, NSError* error);

@interface SonicData : NSObject

+ (SonicData *) sonicDataWithJsonDataString:(NSString*)jsonDataString;

+ (SonicData*) sonicDataFromFile:(NSString*)filePath;

+ (SonicData*) sonicDataWithSonic:(Sonic*)sonic;

+ (SonicData*) sonicDataWithImage:(UIImage*)image andSound:(NSData*)sound;

- (NSDictionary*)dictionaryFromSonicData;

- (id) initWithImage:(UIImage*)image andSound:(NSData*)sound;

+ (NSString*) filePathWithId:(NSString*)id;

@property (nonatomic) Sonic* sonic;
@property (nonatomic) UIImage* image;
@property (nonatomic) NSData* sound;
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) NSData* rawSound;
@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat length;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;

@property (nonatomic) NSURL* localSonicDataFileUrl;
@property (nonatomic) NSURL* remoteSonicDataFileUrl;

- (void) saveToFile;

- (void) setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicDataBlock) sonicBlock;

@end
