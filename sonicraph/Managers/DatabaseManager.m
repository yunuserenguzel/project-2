//
//  CWDatabaseManager.m
//  Crossword
//
//  Created by Yunus Eren Guzel on 6/25/13.
//  Copyright (c) 2013 halici. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DatabaseManager.h"

static DatabaseManager *sharedInstance = nil;

@implementation DatabaseManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (DatabaseManager *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}


- (void)saveContext {
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

-(NSMutableArray *)entitiesWithRequest:(NSFetchRequest *)request forName:(NSString*)entitiyName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entitiyName
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    return mutableFetchResults;
}

-(NSManagedObject *)entityWithRequest:(NSFetchRequest *)request forName:(NSString*)entitiyName
{
    NSMutableArray *mutableFetchResults = [self entitiesWithRequest:request forName:entitiyName];
    if(mutableFetchResults == nil || [mutableFetchResults count] == 0)
        return nil;
    return [mutableFetchResults objectAtIndex:0];
}


-(NSManagedObject*) createEntity:(NSString*)entityName
{
    NSManagedObject* entity =  [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [self saveContext];
    return entity;
}

-(void)deleteObject:(NSManagedObject*)managedObject
{
    [self.managedObjectContext deleteObject:managedObject];
    [self saveContext];
}


/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sonicraph.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(void) flushDatabase
{
    [_managedObjectContext lock];
    NSArray *stores = [_persistentStoreCoordinator persistentStores];
    for(NSPersistentStore *store in stores) {
        [_persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    [_managedObjectContext unlock];
    _managedObjectModel    = nil;
    _managedObjectContext  = nil;
    _persistentStoreCoordinator = nil;
}

@end

