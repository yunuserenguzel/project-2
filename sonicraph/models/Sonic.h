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
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) NSDate * creationDate;
@property (nonatomic) NSString * sonicUrl;
@property (nonatomic) User* owner;
@property (nonatomic) SonicData* sonicData;
@property (nonatomic) BOOL isLikedByMe;
@property (nonatomic) BOOL isResonicedByMe;
@property (nonatomic) NSInteger resonicCount;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger commentCount;


- (void) saveToDatabase;

+ (Sonic*) sonicWithSonicManagedObject:(SonicManagedObject*)sonicManagedObject;

+ (Sonic*) sonicWith:(NSString*)sonicId andLongitude:(NSNumber*)longitude andLatitude:(NSNumber*)latitude andIsPrivate:(NSNumber*)isPrivate andCreationDate:(NSDate*)creationDate andSonicUrl:(NSString*)sonicUrl andOwner:(User*)user;

+ (NSArray*) getFrom:(NSInteger)from to:(NSInteger)to;

+ (Sonic*) getWithId:(NSString*)sonicId;

+ (Sonic*) last;

- (UIImage*) getImage;

- (NSData*) getSound;

- (void) deleteFromDatabase;


@end
