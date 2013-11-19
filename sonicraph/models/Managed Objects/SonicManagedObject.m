//
//  Sonic.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicManagedObject.h"
#import "SonicData.h"
#import "DatabaseManager.h"

@implementation SonicManagedObject

@dynamic sonicId;
@dynamic longitude;
@dynamic latitude;
@dynamic isPrivate;
@dynamic creationDate;
@dynamic sonicUrl;
@dynamic owner;


+ (SonicManagedObject *)last
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // Results should be in descending order of timeStamp.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sonicId" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return (SonicManagedObject*)[[DatabaseManager sharedInstance] entityWithRequest:request forName:@"Sonic"];
}

+ (SonicManagedObject*) createOrFetchForId:(NSString*)sonicId
{
    SonicManagedObject* sonicManagedObject = [SonicManagedObject getWithId:sonicId];
    if(sonicManagedObject == nil) {
        sonicManagedObject = (SonicManagedObject*)[[DatabaseManager sharedInstance] createEntity:@"Sonic"];
        [sonicManagedObject setSonicId:sonicId];
    }
    return sonicManagedObject;
}

+ (SonicManagedObject *)createWith:(NSString *)sonicId andLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude andIsPrivate:(NSNumber*)isPrivate andCreationDate:(NSDate *)creationDate andSonicUrl:(NSString *)sonicUrl andOwner:(UserManagedObject *)userManagedObject
{
    SonicManagedObject* sonicManagedObject = [SonicManagedObject getWithId:sonicId];
    if(sonicManagedObject == nil){
        sonicManagedObject = (SonicManagedObject*)[[DatabaseManager sharedInstance] createEntity:@"Sonic"];
        [sonicManagedObject setSonicId:sonicId];
        [sonicManagedObject setLongitude:longitude];
        [sonicManagedObject setLatitude:latitude];
        [sonicManagedObject setIsPrivate:isPrivate];
        [sonicManagedObject setCreationDate:creationDate];
        [sonicManagedObject setSonicUrl:sonicUrl];
        [sonicManagedObject setOwner:userManagedObject];
        [[DatabaseManager sharedInstance] saveContext];
    }
    return sonicManagedObject;
}

+ (SonicManagedObject *)getWithId:(NSString *)sonicId
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"sonicId = %@",sonicId];
    [request setPredicate:predicate];
    SonicManagedObject* sonic = (SonicManagedObject*)[[DatabaseManager sharedInstance] entityWithRequest:request forName:@"Sonic"];
    return sonic;
}

+ (NSArray *)getFrom:(NSInteger)from to:(NSInteger)to
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSArray* sonics = [[DatabaseManager sharedInstance] entitiesWithRequest:request forName:@"Sonic"];
    return [sonics sortedArrayUsingComparator:^NSComparisonResult(SonicManagedObject* obj1, SonicManagedObject* obj2) {
        return [obj2.creationDate compare:obj1.creationDate];
    }];
}

- (void)save
{
    [[DatabaseManager sharedInstance] saveContext];
}

- (void) deleteFromDatase
{
    [[DatabaseManager sharedInstance] deleteObject:self];
}
@end
