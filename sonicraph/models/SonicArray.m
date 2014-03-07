//
//  SonicArray.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/17/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicArray.h"
#import "TypeDefs.h"

@interface SonicArray ()

@property NSMutableArray* sonics;

@end

@implementation SonicArray

- (id)init
{
    if(self = [super init]){
        self.sonics = [NSMutableArray new];
    }
    return self;
}

- (void) importSonicsWithArray:(NSArray*)array
{
    [array enumerateObjectsUsingBlock:^(Sonic* sonic, NSUInteger idx, BOOL *stop) {
        if(sonic.sonicId == nil){
            NSLog(@"[SonicArray.m %d] Warning! sonic id is nil", __LINE__);
        }
        Sonic* cachedSonic = [self getSonicWithId:sonic.sonicId];
        if(cachedSonic){
            [cachedSonic updateWithSonic:sonic];
        } else {
            cachedSonic = sonic;
            [self.sonics addObject:cachedSonic];
        }
    }];
    [self sort];

}

- (Sonic*) getSonicWithId:(NSString*)sonicId
{
    for (Sonic* sonic in self.sonics) {
        if ([[sonic sonicId] isEqualToString:sonicId]) {
            return sonic;
        }
    }
    return nil;
}

- (BOOL) deleteSonicWithId:(NSString*)sonicId
{
    for (Sonic* sonic in self.sonics) {
        if ([[sonic sonicId] isEqualToString:sonicId]) {
            [self.sonics removeObject:sonic];
            return YES;
        }
    }
    return NO;
}

- (Sonic *)objectAtIndex:(NSInteger)index
{
    return [self.sonics objectAtIndex:index];
}

- (void)addObject:(Sonic *)sonic
{
    [self importSonicsWithArray:@[sonic]];
}

- (NSUInteger)count
{
    return [self.sonics count];
}

- (void) sort
{
    [self.sonics sortUsingComparator:^NSComparisonResult(Sonic* sonic1, Sonic* sonic2) {
        return [sonic2.creationDate compare:sonic1.creationDate];
    }];
}

@end
