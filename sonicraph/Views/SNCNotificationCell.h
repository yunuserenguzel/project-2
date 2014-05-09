//
//  SNCNotificationCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "Configurations.h"
#import "FadingImageView.h"

@interface SNCNotificationCell : UITableViewCell

@property (nonatomic) Notification* notification;

@property UIImageView* notificationTypeImageView;
@property FadingImageView* profileImageView;
@property UILabel* fullnameLabel;
@property UILabel* usernameLabel;
@property UILabel* notificationTextLabel;
@property UILabel* createdAtLabel;
@end
