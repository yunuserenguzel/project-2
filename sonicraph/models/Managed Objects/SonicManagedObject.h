//
//  Sonic.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UserManagedObject.h"

@class Sonic;

@interface SonicManagedObject : NSManagedObject

@property (nonatomic, retain) NSString * sonicId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * sonicUrl;
@property (nonatomic, retain) NSManagedObject *owner;
@property Sonic* sonic;

+ (SonicManagedObject*) createWith:(NSString*)sonicId andLongitude:(NSNumber*)longitude andLatitude:(NSNumber*)latitude andIsPrivate:(NSNumber*)isPrivate andCreationDate:(NSDate*)creationDate andSonicUrl:(NSString*)sonicUrl andOwner:(UserManagedObject*)userManagedObject;

+ (NSArray*) getFrom:(NSInteger)from to:(NSInteger)to;

+ (SonicManagedObject*) getWithId:(NSString*)sonicId;

- (UIImage*) getImage;

- (NSData*) getSound;

@end
