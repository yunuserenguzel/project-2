//
//  SNCRecordViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/20/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SonicraphMediaManager.h"
#import "TypeDefs.h"
#import "SNCAppDelegate.h"

@interface SNCCameraViewController : UIViewController <SonicraphMediaProtocol>

@property SonicraphMediaManager* mediaManager;

@end
