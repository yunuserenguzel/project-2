//
//  SNCAPIManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIManager.h"
#import "JSONKit.h"
#import "Sonic.h"
#import "SonicManagedObject.h"
#import "UserManagedObject.h"
#import "TypeDefs.h"

@implementation SNCAPIManager

NSString* token = @"SNCKL001527bedc56798a527bedc568b28527bedc56ac69";

+ (SNCAPIConnector*)connector
{
    static SNCAPIConnector* connector = nil;
    if(connector == nil){
        connector = [SNCAPIConnector sharedInstance];
    }
    return connector;
}
+ (void)createSonic:(Sonic *)sonic withCompletionBlock:(CompletionBlock)completionBlock
{
    NSString* sonicData = [[sonic dictionaryFromSonic] JSONString];
    NSLog(@"length: %d",[sonicData lengthOfBytesUsingEncoding:NSStringEncodingConversionAllowLossy]);
    NSString* operation = @"create_sonic";
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token, @"latitude":[NSNumber numberWithFloat:sonic.latitude], @"longitude":[NSNumber numberWithFloat:sonic.longitude], @"sonic":sonicData}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         completionBlock(responseDictionary);
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

+ (void) getMySonicsWithCompletionBlock:(Block)completionBlock
{
    NSNumber* pageNumber = [NSNumber numberWithInt:0];
    NSNumber* pageCount = [NSNumber numberWithInt:20];
    NSString* operation = @"get_my_sonics";
    
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token,@"page_number":pageNumber,@"page_count":pageCount}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         for (NSDictionary* sonicDict in [responseDictionary objectForKey:@"sonics"]) {
             SonicManagedObject* sonicManagedObject = [SonicManagedObject getWithId:[responseDictionary objectForKey:@"sonic_id"]];
             if(sonicManagedObject == nil){
//                 UserManagedObject* owner = [UserManagedObject crea]
//                 [sonicDict objectForKey:@"user_id"]
                 sonicManagedObject = [SonicManagedObject createWith:[sonicDict objectForKey:@"sonic_id"]
                                                        andLongitude:[NSNumber numberWithFloat:[[sonicDict objectForKey:@"longitude"] floatValue]]
                                                         andLatitude:[NSNumber numberWithFloat:[[sonicDict objectForKey:@"latitude"] floatValue]]
                                                        andIsPrivate:[NSNumber numberWithBool:[[sonicDict objectForKey:@"longitude"] boolValue]]
                                                     andCreationDate:[NSDate dateFromRFC1123:[sonicDict objectForKey:@"creation_date"]]
                                                         andSonicUrl:[sonicDict objectForKey:@"sonic_url"]
                                                            andOwner:nil];
                 
                 Sonic* sonic = [Sonic sonicFromServerResponseDictionary:sonicDict];
                 [sonic setSonicManagedObject:sonicManagedObject];
                 [sonic saveToFile];
             }
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicsAreLoaded object:nil];
         if(completionBlock){
             completionBlock();
         }
         
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

@end
