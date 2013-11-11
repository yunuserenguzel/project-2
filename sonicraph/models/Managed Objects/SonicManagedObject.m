//
//  Sonic.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicManagedObject.h"
#import "Sonic.h"
#import "DatabaseManager.h"

@implementation SonicManagedObject

@dynamic sonicId;
@dynamic longitude;
@dynamic latitude;
@dynamic isPrivate;
@dynamic creationDate;
@dynamic sonicUrl;
@dynamic owner;

@synthesize sonic = _sonic;


+ (SonicManagedObject *)createWith:(NSString *)sonicId andLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude andIsPrivate:(NSNumber*)isPrivate andCreationDate:(NSDate *)creationDate andSonicUrl:(NSString *)sonicUrl andOwner:(UserManagedObject *)userManagedObject
{
    SonicManagedObject* sonic = [SonicManagedObject getWithId:sonicId];
    if(sonic == nil){
        sonic = (SonicManagedObject*)[[DatabaseManager sharedInstance] createEntity:@"Sonic"];
        [sonic setSonicId:sonicId];
        [sonic setLongitude:longitude];
        [sonic setLatitude:latitude];
        [sonic setIsPrivate:isPrivate];
        [sonic setCreationDate:creationDate];
        [sonic setSonicUrl:sonicUrl];
        [sonic setOwner:userManagedObject];
        [[DatabaseManager sharedInstance] saveContext];
    }
    return sonic;
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
    return [[DatabaseManager sharedInstance] entitiesWithRequest:request forName:@"Sonic"];
}


- (UIImage *)getImage
{
    return [[self sonic] image];
}

- (NSData *)getSound
{
    return [[self sonic] sound];
}

- (Sonic *)sonic
{
    if(_sonic == nil){
        self.sonic = [Sonic readFromFile:self];
    }
    return _sonic;
}

- (void)setSonic:(Sonic *)sonic
{
    _sonic = sonic;
    sonic.sonicManagedObject = self;
}

@end
