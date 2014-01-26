//
//  SettingsTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SettingsTableCell.h"
#import <QuartzCore/QuartzCore.h>


CGFloat heightForIdentifier(NSString* identifier)
{
    if([identifier isEqualToString:SettingsTableCellImageValueIdentifier]){
        return 120.0;
    }
    else {
        return 44.0;
    }
}
@interface SettingsTableCell ()

@property UILabel* keyLabel;
@property UITextField* stringValueField;
@property UIImageView* imageValueView;
@end


@implementation SettingsTableCell

- (CGRect) keyLabelFrame
{
    return CGRectMake(10.0, 0.0, 100.0, 44.0);
}

- (CGRect) stringValueFieldFrame
{
    return CGRectMake(120.0, 0.0, 190.0, 44.0);
}

- (CGRect) imageValueViewFrame
{
    return CGRectMake(200.0, 10.0, 100.0, 100.0);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
        if([reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier]){
            [self initTextField];
        }
        else if([reuseIdentifier isEqualToString:SettingsTableCellImageValueIdentifier]){
            [self initImageValueView];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) initViews
{
    self.keyLabel = [[UILabel alloc] initWithFrame:[self keyLabelFrame]];
    [self.contentView addSubview:self.keyLabel];
    self.keyLabel.font = [self.keyLabel.font fontWithSize:14.0];
    [self.keyLabel setTextAlignment:NSTextAlignmentLeft];
}

- (void) initTextField
{
    self.stringValueField = [[UITextField alloc] initWithFrame:[self stringValueFieldFrame]];
    [self.contentView addSubview:self.stringValueField];
    [self.stringValueField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.stringValueField setTextAlignment:NSTextAlignmentRight];
    [self.stringValueField setFont:[self.stringValueField.font fontWithSize:14.0]];
}

- (void) initImageValueView
{
    self.imageValueView = [[UIImageView alloc] initWithFrame:[self imageValueViewFrame]];
    [self.contentView addSubview:self.imageValueView];
    [self.imageValueView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageValueView setClipsToBounds:YES];
    self.imageValueView.layer.cornerRadius = 10.0;
}

- (void) setKey:(NSString *)key
{
    _key = key;
    self.keyLabel.text = key;
}

- (void) setValue:(id)value
{
    _value = value;
    if ([self.reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier]) {
        self.stringValueField.text = value;
    } else if([self.reuseIdentifier isEqualToString:SettingsTableCellImageValueIdentifier]){
        self.imageValueView.image = value;
    }
}

- (void) textFieldValueChanged:(UITextField*)textField
{
    
}



@end
