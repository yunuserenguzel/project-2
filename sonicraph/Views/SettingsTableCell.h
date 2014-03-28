//
//  SettingsTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Configurations.h"

#define SettingsTableCellStringValueIdentifier @"SettingsTableCellStringValueIdentifier"
#define SettingsTableCellDateValueIdentifier @"SettingsTableCellDateValueIdentifier"
#define SettingsTableCellPasswordValueIdentifier @"SettingsTableCellPasswordValueIdentifier"
#define SettingsTableCellImageValueIdentifier @"SettingsTableCellImageValueIdentifier"
#define SettingsTableCellGenderValueIdentifier @"SettingsTableCellGenderValueIdentifier"
#define SettingsTableCellButtonIdentifier @"SettingsTableCellButtonIdentifier"

CGFloat heightForIdentifier(NSString* identifier);

@protocol SettingsTableCellProtocol

- (void) valueChanged:(id)value forKey:(NSString*)string;

@end


@interface SettingsField : NSObject
@property NSString* key;
@property NSString* serverKey;
@property id value;
@property NSString* type;
@property BOOL required;
+ (SettingsField*) k:(NSString*)key sK:(NSString*)serverKey v:(id)value t:(NSString*)type;
+(SettingsField *)k:(NSString *)key sK:(NSString*)serverKey v:(id)value t:(NSString *)type r:(BOOL)required;

@end


@interface SettingsTableCell : UITableViewCell <UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic) NSString* key;
@property (nonatomic) BOOL required;
@property (nonatomic) id value;
@property (weak) UITableViewController<SettingsTableCellProtocol>* delegate;


@end
