//
//  Sonic.m
//  ;
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"
#import "SonicData.h"
#import "SonicManagedObject.h"
#import "TypeDefs.h"

@implementation Sonic

+ (Sonic *)sonicWithSonicManagedObject:(SonicManagedObject *)sonicManagedObject
{
    if(sonicManagedObject == nil) return nil;
    Sonic* sonic = [[Sonic alloc] init];
    sonic.sonicId = sonicManagedObject.sonicId;
    sonic.longitude = [sonicManagedObject.longitude floatValue];
    sonic.latitude = [sonicManagedObject.latitude floatValue];
    sonic.isPrivate = [sonicManagedObject.isPrivate boolValue];
    sonic.isLikedByMe = [sonicManagedObject.isLikedByMe boolValue];
    sonic.isResonicedByMe = [sonicManagedObject.isResonicedByMe boolValue];
    sonic.likeCount = [sonicManagedObject.likeCount integerValue];
    sonic.commentCount = [sonicManagedObject.commentCount integerValue];
    sonic.resonicCount = [sonicManagedObject.resonicCount integerValue];
    sonic.creationDate = sonicManagedObject.creationDate;
    sonic.sonicUrl = sonicManagedObject.sonicUrl;
    sonic.owner = [User userWithManagedObject:sonicManagedObject.owner];
    return sonic;    
}

- (SonicData *)sonicData
{
    if(_sonicData == nil){
        self.sonicData = [SonicData sonicDataWithSonic:self];
    }
    return _sonicData;
}

- (void)setSonic:(SonicData *)sonicData
{
    _sonicData = sonicData;
    sonicData.sonic = self;
}

+(Sonic *)getWithId:(NSString *)sonicId
{
    return [Sonic sonicWithSonicManagedObject:[SonicManagedObject getWithId:sonicId]];
}

+ (Sonic *)sonicWith:(NSString *)sonicId andLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude andIsPrivate:(NSNumber *)isPrivate andCreationDate:(NSDate *)creationDate andSonicUrl:(NSString *)sonicUrl andOwner:(User *)user
{
    
    Sonic* sonic = [Sonic getWithId:sonicId];
    if(!sonic) sonic = [[Sonic alloc] init];
    sonic.sonicId = sonicId;
    sonic.longitude = [longitude floatValue];
    sonic.latitude = [latitude floatValue];
    sonic.isPrivate = [isPrivate boolValue];
    sonic.creationDate = creationDate;
    sonic.sonicUrl = sonicUrl;
    sonic.owner = user;
    return sonic;
}


- (UIImage *)getImage
{
    return [[self sonicData] image];
}

- (NSData *)getSound
{
    return [[self sonicData] sound];
}

- (void)saveToDatabase
{
    SonicManagedObject* sonicManagedObject = [SonicManagedObject createOrFetchForId:self.sonicId];
    sonicManagedObject.latitude = [NSNumber numberWithFloat:self.latitude];
    sonicManagedObject.longitude = [NSNumber numberWithFloat:self.longitude];
    sonicManagedObject.isPrivate = [NSNumber numberWithBool:self.isPrivate];
    sonicManagedObject.isLikedByMe = [NSNumber numberWithBool:self.isLikedByMe];
    sonicManagedObject.isResonicedByMe = [NSNumber numberWithBool:self.isResonicedByMe];
    sonicManagedObject.likeCount = [NSNumber numberWithInteger:self.likeCount];
    sonicManagedObject.commentCount = [NSNumber numberWithInteger:self.commentCount];
    sonicManagedObject.resonicCount = [NSNumber numberWithInteger:self.resonicCount];
    sonicManagedObject.creationDate = self.creationDate;
    sonicManagedObject.sonicUrl = self.sonicUrl;
    [self.owner saveToDatabase];
    sonicManagedObject.owner = self.owner.userManagedObject;
    [sonicManagedObject save];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NotificationSonicSaved
     object:self];
}

+ (Sonic *)last
{
    return [Sonic sonicWithSonicManagedObject:[SonicManagedObject last]];
}

+ (NSArray *)getFrom:(NSInteger)from to:(NSInteger)to
{
    NSArray* managedObjects = [SonicManagedObject getFrom:from to:to];
    NSMutableArray* sonics = [NSMutableArray array];
    [managedObjects enumerateObjectsUsingBlock:^(SonicManagedObject* sonicManagedObject, NSUInteger idx, BOOL *stop) {
        [sonics addObject:[Sonic sonicWithSonicManagedObject:sonicManagedObject]];
    }];
    
    return sonics;
}

- (void)deleteFromDatabase
{
    SonicManagedObject* sonicManagedObject = [SonicManagedObject getWithId:self.sonicId];
    [sonicManagedObject deleteFromDatase];
}
@end
