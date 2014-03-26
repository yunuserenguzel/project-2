//
//  SonicPresenter.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 25/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"
#import "SNCNavigationViewController.h"
#import "SNCSonicViewController.h"

@interface SonicPresenter : NSObject

+ (SonicPresenter*) sharedInstance;

@property (readonly,nonatomic) NSString* sonicId;
@property (readonly,nonatomic) Sonic* sonic;

- (void) presentSonicWithId:(NSString*)sonicId;


@end
