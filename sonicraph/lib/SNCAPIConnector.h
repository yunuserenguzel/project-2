//
//  SNCAPIConnector.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"
#import "TypeDefs.h"


typedef void (^CompletionBlock) (NSDictionary *responseDictionary);
typedef void (^Block) ();

@interface SNCAPIConnector : MKNetworkEngine

+ (SNCAPIConnector*) sharedInstance;


- (MKNetworkOperation *) postRequestWithParams:(NSDictionary*) params
                                     useToken:(BOOL)useToken
                                  andOperation:(NSString*)opearation
                            andCompletionBlock:(CompletionBlock) completionBlock
                                 andErrorBlock:(ErrorBlock)errorBlock;

- (MKNetworkOperation*) getRequestWithParams:(NSDictionary*) params
                                   useToken:(BOOL)useToken
                                andOperation:(NSString*)opearation
                          andCompletionBlock:(CompletionBlock) completionBlock
                               andErrorBlock:(ErrorBlock)errorBlock;

- (MKNetworkOperation*) uploadFileRequestWithParams:(NSDictionary*) params
                                          useToken:(BOOL)useToken
                                           andFiles:(NSArray*) files
                                       andOperation:(NSString*)opearation
                                 andCompletionBlock:(CompletionBlock) completionBlock
                                      andErrorBlock:(ErrorBlock)errorBlock;


@end
