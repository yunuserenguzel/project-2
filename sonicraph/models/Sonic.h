//
//  Sonickle.h
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SonicklesUserDefaultsKey @"SonicklesUserDefaultsKey"
#import "UIImage+scaleToSize.h"

@class Sonic;

typedef void (^SonicBlock) (Sonic* sonic, NSError* error);

@interface Sonic : NSObject

+ (Sonic*) sonicFromDictionary:(NSDictionary*)dictionary;

+ (Sonic*) readFromFile:(NSString*)fileName;

+ (Sonic*) sonickleWithImage:(UIImage*)image andSound:(NSData*)sound withId:(NSString*)sonickleId;

- (NSDictionary*)dictionaryFromSonic;

- (id) initWithImage:(UIImage*)image andSound:(NSData*)sound withId:(NSString*)sonickleId;

@property (nonatomic) NSString* sonicId;
@property (nonatomic) UIImage* image;
@property (nonatomic) NSData* sound;
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) NSData* rawSound;
@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat length;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;

@property (nonatomic) NSURL* localSonicFileUrl;
@property (nonatomic) NSURL* remoteSonicFileUrl;

- (void) saveToFile;
- (void) readFromFile;

- (void)setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock;

@end
