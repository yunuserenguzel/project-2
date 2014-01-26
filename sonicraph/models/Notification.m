//
//  Notification.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "Notification.h"

NotificationType notificationTypeFromString(NSString* string)
{
    if(string == nil || [string isKindOfClass:[NSNull class]]){
        return NotificationTypeUnknown;
    }
    else if([string isEqualToString:@"like"]){
        return NotificationTypeLike;
    }
    else if([string isEqualToString:@"comment"]){
        return NotificationTypeComment;
    }
    else if([string isEqualToString:@"follow"]){
        return NotificationTypeFollow;
    }
    else if([string isEqualToString:@"resonic"]){
        return NotificationTypeResonic;
    }
    return NotificationTypeUnknown;
}
@implementation Notification

@end
