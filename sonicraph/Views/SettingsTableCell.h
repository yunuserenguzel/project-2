//
//  SettingsTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SettingsTableCellStringValueIdentifier @"SettingsTableCellStringValueIdentifier"
#define SettingsTableCellDateValueIdentifier @"SettingsTableCellDateValueIdentifier"
#define SettingsTableCellPasswordValueIdentifier @"SettingsTableCellPasswordValueIdentifier"
#define SettingsTableCellImageValueIdentifier @"SettingsTableCellImageValueIdentifier"

CGFloat heightForIdentifier(NSString* identifier);

@protocol SettingsTableCellProtocol

- (void) valueChanged:(id)value forKey:(NSString*)string;

@end

@interface SettingsTableCell : UITableViewCell

@property (nonatomic) NSString* key;
@property (nonatomic) id value;
@property id<SettingsTableCellProtocol> delegate;


@end