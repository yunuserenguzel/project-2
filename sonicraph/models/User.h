//
//  User.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserManagedObject;

@interface User : NSObject


+ (User*) userWithManagedObject:(UserManagedObject*)userManagedObject;
- (void) saveToDatabase;

@property (nonatomic) NSString* fullName;

@end
