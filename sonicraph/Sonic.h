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


+ (Sonic*) sonickleFromDictionary:(NSDictionary*)dictionary;

+ (Sonic*) readFromFile:(NSString*)fileName;


+ (Sonic*) sonickleWithImage:(UIImage*)image andSound:(NSData*)sound withId:(NSString*)sonickleId;

- (NSDictionary*)dictionaryFromSonickle;


- (id) initWithImage:(UIImage*)image andSound:(NSData*)sound withId:(NSString*)sonickleId;

@property (nonatomic) NSString* sonicId;
@property (nonatomic) UIImage* image;
@property (nonatomic) NSData* sound;
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) NSData* rawSound;
@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat length;

- (void) saveToFile;
- (void)setSoundCroppingFrom:(CGFloat)from to:(CGFloat)to withCompletionHandler:(SonicBlock) sonicBlock;
@end
