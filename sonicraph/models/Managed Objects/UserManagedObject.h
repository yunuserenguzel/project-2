//
//  UserManagedObject.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sonic;

@interface UserManagedObject : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSSet *sonics;
@end

@interface UserManagedObject (CoreDataGeneratedAccessors)

- (void)addSonicsObject:(Sonic *)value;
- (void)removeSonicsObject:(Sonic *)value;
- (void)addSonics:(NSSet *)values;
- (void)removeSonics:(NSSet *)values;

@end
