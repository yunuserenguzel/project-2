//
//  SNCNotificationCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCNotificationCell.h"
#import "NSDate+NVTimeAgo.h"
#import <QuartzCore/QuartzCore.h>

@implementation SNCNotificationCell

- (CGRect) notificationTypeImageViewFrame
{
    return CGRectMake(0.0, 0.0, 30.0, NotificationTableCellHeight);
}

- (CGRect) profileImageViewFrame
{
    return CGRectMake(33.0, (NotificationTableCellHeight - 44.0) * 0.5 , 44.0, 44.0);
}

- (CGRect) fullnameLabelFrame
{
    return CGRectMake(88.0, 0.0, 150.0, 28.0);
}

- (CGRect) createAtLabelFrame
{
    return CGRectMake(260.0, 0.0, 55.0, 22.0);
}

- (CGRect) notificationTextLabelFrame
{
    return CGRectMake(88.0, 22.0, 210.0, 42.0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}
- (void) initViews
{
    self.notificationTypeImageView = [[UIImageView alloc] initWithFrame:[self notificationTypeImageViewFrame]];
    [self.contentView addSubview:self.notificationTypeImageView];
    [self.notificationTypeImageView setContentMode:UIViewContentModeCenter];
    
    self.profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageViewFrame]];
    [self.contentView addSubview:self.profileImageView];
    self.profileImageView.layer.cornerRadius = 2.0;
    [self.profileImageView setClipsToBounds:YES];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    [self.contentView addSubview:self.fullnameLabel];
    
    self.notificationTextLabel = [[UILabel alloc] initWithFrame:[self notificationTextLabelFrame]];
    [self.contentView addSubview:self.notificationTextLabel];
    self.notificationTextLabel.numberOfLines = 0;
    self.notificationTextLabel.font = [self.notificationTextLabel.font fontWithSize:14.0];
    
    self.createdAtLabel = [[UILabel alloc] initWithFrame:[self createAtLabelFrame]];
    [self.contentView addSubview:self.createdAtLabel];
    self.createdAtLabel.font = [self.createdAtLabel.font fontWithSize:10.0];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(Notification *)notification
{
    _notification = notification;
    [self configureViews];
}

- (void) configureViews
{
    self.fullnameLabel.text = self.notification.byUser.fullName;
    self.createdAtLabel.text = [self.notification.createdAt formattedAsTimeAgo];
    self.profileImageView.image = SonicPlaceholderImage;
    [self updateNotificationTextAndImage];
    [self.notification.byUser getThumbnailProfileImageWithCompletionBlock:^(UIImage* image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileImageView.image = image;
        });
    }];
}

- (void) updateNotificationTextAndImage
{
    NSString* text = nil;
    UIImage* image;
    if(self.notification.notificationType == NotificationTypeComment){
        text = @"is commented on one of your sonics";
        image = [self notificationTypeImageLike];
    }
    else if(self.notification.notificationType == NotificationTypeFollow){
        text = @"is now following you";
        image = [self notificationTypeImageFollow];
    }
    else if(self.notification.notificationType == NotificationTypeLike){
        text = @"is liked one of your sonics";
        image = [self notificationTypeImageLike];
    }
    else if(self.notification.notificationType == NotificationTypeResonic){
        text = @"is resoniced one of your sonics";
        image = [self notificationTypeImageResonic];
    }
    self.notificationTextLabel.text = text;
    self.notificationTypeImageView.image = image;
}
- (UIImage*) notificationTypeImageLike
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"HeartGrey.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageResonic
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"ReSonicGrey.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageComment
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"CommentGrey.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageFollow
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"UserGrey.png"];
    }
    return image;
}


@end
