//
//  SonicComment.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/1/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"
@interface SonicComment : NSObject

@property NSString* commentId;
@property Sonic* sonic;
@property NSString* text;
@property User* user;
@property NSDate* createdAt;

@end
