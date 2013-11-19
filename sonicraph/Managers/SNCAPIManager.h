//
//  SNCAPIManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonicData.h"
#import "SNCAPIConnector.h"

typedef void (^CompletionArrayBlock) (NSArray *sonics);


@interface SNCAPIManager : NSObject

+ (void) createSonic:(SonicData *)sonic withCompletionBlock:(CompletionBlock)completionBlock;

+ (void) getUserSonics:(UserManagedObject*)user withCompletionBlock:(CompletionArrayBlock)completionBlock;

+ (void) getSonicsBefore:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock;

+ (void) getSonicsAfter:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock;

+ (void) getLatestSonicsWithCompletionBlock:(Block)completionBlock;

+ (void) getSonicsWithParams:(NSDictionary*)dictionary saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(Block)completionBlock;

+ (void) getSonic:(NSURL*)sonicUrl withSonicBlock:(SonicBlock)sonicBlock;


@end
