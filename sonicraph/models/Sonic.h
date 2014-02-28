//
//  Sonic.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@class SonicData;
@class SonicManagedObject;

@interface Sonic : NSObject

@property (nonatomic) NSString * sonicId;
@property (nonatomic) NSString * sonicUrlString;
@property (nonatomic) NSString* tags;
@property (nonatomic) NSDate * creationDate;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) NSInteger resonicCount;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) BOOL isLikedByMe;
@property (nonatomic) BOOL isResonicedByMe;
@property (nonatomic) BOOL isResonic;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) User* owner;
@property (nonatomic) SonicData* sonicData;
@property (nonatomic) Sonic* originalSonic;
@property (nonatomic) NSString* shareUrlString;
@property (nonatomic) NSString* sonicThumbnailUrlString;

- (UIImage*) getImage;

- (NSData*) getSound;

- (void) updateWithSonic:(Sonic*)sonic;

- (BOOL) isMySonic;

@end
