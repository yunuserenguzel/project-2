//
//  Sonickle.h
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/31/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+scaleToSize.h"
#import "SonicManagedObject.h"

#define SonicklesUserDefaultsKey @"SonicklesUserDefaultsKey"

@class Sonic;

typedef void (^SonicBlock) (Sonic* sonic, NSError* error);

@interface Sonic : NSObject

+ (Sonic*) sonicFromServerResponseDictionary:(NSDictionary*)dictionary;

//+ (Sonic*) sonicFromDictionary:(NSDictionary*)dictionary;

+ (Sonic*) readFromFile:(SonicManagedObject*)sonicManagedObject;

+ (Sonic*) sonickleWithImage:(UIImage*)image andSound:(NSData*)sound;

- (NSDictionary*)dictionaryFromSonic;

- (id) initWithImage:(UIImage*)image andSound:(NSData*)sound;

@property (nonatomic) SonicManagedObject* sonicManagedObject;
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

- (void) setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock;

@end
