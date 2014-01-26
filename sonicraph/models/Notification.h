//
//  Notification.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sonic.h"
#import "User.h"
#import "SonicComment.h"

typedef enum NotificationType {
    NotificationTypeUnknown = 0,
    NotificationTypeLike = 111,
    NotificationTypeComment = 112,
    NotificationTypeResonic = 113,
    NotificationTypeFollow = 114,
}
NotificationType;

NotificationType notificationTypeFromString(NSString* string);

@interface Notification : NSObject

@property NSString* notificationId;
@property NSDate* createdAt;
@property NotificationType notificationType;
@property BOOL isRead;
@property User* byUser;
@property Sonic* toSonic;
@property SonicComment* sonicComment;


@end
