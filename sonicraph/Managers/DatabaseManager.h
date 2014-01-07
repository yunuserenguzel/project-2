//
//  CWDatabaseManager.h
//  Crossword
//
//  Created by Yunus Eren Guzel on 6/25/13.
//  Copyright (c) 2013 halici. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseManager : NSObject


@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DatabaseManager *)sharedInstance;

- (void)saveContext;
- (NSManagedObject*) createEntity:(NSString*)entityName;

- (NSMutableArray *)entitiesWithRequest:(NSFetchRequest *)request forName:(NSString*)entitiyName;
- (NSManagedObject *)entityWithRequest:(NSFetchRequest *)request forName:(NSString*)entitiyName;

- (void) deleteObject:(NSManagedObject*)managedObject;

- (void) flushDatabase;

@end
