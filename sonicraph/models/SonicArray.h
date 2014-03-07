//
//  SonicArray.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/17/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"

@interface SonicArray : NSMutableArray

- (void) importSonicsWithArray:(NSArray*)array;

- (void) addObject:(Sonic*)sonic;

- (Sonic*) objectAtIndex:(NSInteger)index;

- (BOOL) deleteSonicWithId:(NSString*)sonicId;

@property (readonly,nonatomic) NSUInteger count;
@end
