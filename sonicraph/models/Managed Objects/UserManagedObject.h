//
//  UserManagedObject.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SonicData;

@interface UserManagedObject : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSSet *sonics;

+ (UserManagedObject*) createOrFetchWithId:(NSString*)userId;
+ (UserManagedObject*) createUserWith:(NSString*)userId andUserName:(NSString*)userName andRealName:(NSString*)realName andImage:(NSString*)image;

+ (UserManagedObject*) getUser:(NSString*)userId;

+ (UserManagedObject*) last;

- (void) save;

@end

@interface UserManagedObject (CoreDataGeneratedAccessors)

- (void)addSonicsObject:(SonicData *)value;
- (void)removeSonicsObject:(SonicData *)value;
- (void)addSonics:(NSSet *)values;
- (void)removeSonics:(NSSet *)values;

@end
