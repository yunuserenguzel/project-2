//
//  SNCAPIConnector.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIConnector.h"

@implementation SNCAPIConnector


+ (SNCAPIConnector *)sharedInstance
{
    static SNCAPIConnector* sharedInstance = nil;
    if(sharedInstance == nil){
        sharedInstance = [[SNCAPIConnector alloc] initWithHostName:@"www.sonicraph.com/api"];
    }
    return sharedInstance;
}

- (void) postRequestWithParams:(NSDictionary*) params
                  andOperation:(NSString*) opearation
            andCompletionBlock:(CompletionBlock) completionBlock
                 andErrorBlock:(ErrorBlock) errorBlock
{
    
    MKNetworkOperation* op = [self operationWithPath:opearation
                                              params:params
                                          httpMethod:@"POST"];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"response string: %@",[completedOperation responseString]);
        NSDictionary *responseDictionary = [completedOperation responseJSON];
        
        if([[responseDictionary valueForKey:@"error"] boolValue] == true){
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:[[responseDictionary objectForKey:@"error_code"] intValue]
                                                userInfo:@{NSLocalizedDescriptionKey : [responseDictionary valueForKey:@"error_message"]}];
            if(errorBlock != nil)
                errorBlock(apiError);
        }
        else{
            completionBlock(responseDictionary);
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (error.domain == NSURLErrorDomain && error.code == -1009) {
            NSError *connectionError = [NSError errorWithDomain:@"ConnectionError"
                                                           code:-102
                                                       userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CONNECTION_ERROR", nil)}];
            if(errorBlock != nil)
                errorBlock(connectionError);
        } else {
            if(errorBlock != nil)
                errorBlock(error);
        }
    }];
    
    [self enqueueOperation:op];
    
}

@end
