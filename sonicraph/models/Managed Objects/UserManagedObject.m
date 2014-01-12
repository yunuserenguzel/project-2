//
//  UserManagedObject.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/11/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "UserManagedObject.h"
#import "SonicData.h"
#import "DatabaseManager.h"

@implementation UserManagedObject

@dynamic image;
@dynamic username;
@dynamic fullname;
@dynamic userId;
@dynamic sonics;
@dynamic followerCount;
@dynamic followingCount;
@dynamic sonicCount;
@dynamic bio;
@dynamic location;
@dynamic website;

+ (UserManagedObject*) createOrFetchWithId:(NSString*)userId
{
    UserManagedObject* userManagedObject = [UserManagedObject getUser:userId];
    if(userManagedObject == nil){
        userManagedObject = (UserManagedObject*)[[DatabaseManager sharedInstance] createEntity:@"User"];
        userManagedObject.userId = userId;
    }
    return userManagedObject;
}


+ (UserManagedObject *)getUser:(NSString *)userId
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [request setPredicate:predicate];
    UserManagedObject* user = (UserManagedObject*)[[DatabaseManager sharedInstance] entityWithRequest:request forName:@"User"];
    return user;
}

+ (UserManagedObject *)last{
    return nil;
}

- (void) save
{
    [[DatabaseManager sharedInstance] saveContext];
}


@end
