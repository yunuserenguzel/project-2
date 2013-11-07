//
//  SNCAPIManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIManager.h"
#import "JSONKit.h"
@implementation SNCAPIManager

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
    NSString* token = @"SNCKL001527bedc56798a527bedc568b28527bedc56ac69";
    [[SNCAPIConnector sharedInstance]
     postRequestWithParams:@{@"token":token, @"latitude":[NSNumber numberWithFloat:sonic.latitude ], @"longitude":[NSNumber numberWithFloat:sonic.longitude], @"sonic":sonicData}
     andOperation:operation
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         completionBlock(responseDictionary);
     }
     andErrorBlock:^(NSError *error) {
         
     }];
}

@end
