//
//  SettingsTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SettingsTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "TypeDefs.h"

CGFloat heightForIdentifier(NSString* identifier)
{
    if([identifier isEqualToString:SettingsTableCellImageValueIdentifier]){
        return 120.0;
    }
    else if([identifier isEqualToString:SettingsTableCellDateValueIdentifier]){
        return 44.0;
    }
    else {
        return 44.0;
    }
}
@interface SettingsTableCell ()

@property UILabel* keyLabel;
@property UITextField* stringValueField;
@property UIImageView* imageValueView;
@property UIDatePicker* dateValuePicker;
@end


@implementation SettingsTableCell
{
    UIImagePickerController* imagePickerController;
}
//- (CGRect) keyLabelFrame
//{
//    return CGRectMake(10.0, 0.0, 100.0, 44.0);
//}

- (CGRect) stringValueFieldFrame
{
    return CGRectMake(10.0, 0.0, 300.0, 44.0);
}

- (CGRect) imageValueViewFrame
{
    return CGRectMake(110.0, 10.0, 100.0, 100.0);
}

- (CGRect) dateValuePickerFrame
{
    return CGRectMake(10, 0.0, 300.0, 44.0);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
        if([reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier])
        {
            [self initTextField];
        }
        else if([reuseIdentifier isEqualToString:SettingsTableCellImageValueIdentifier])
        {
            [self initImageValueView];
        }
        else if([reuseIdentifier isEqualToString:SettingsTableCellDateValueIdentifier])
        {
            [self initDateValueView];
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
//    self.keyLabel = [[UILabel alloc] initWithFrame:[self keyLabelFrame]];
//    [self.contentView addSubview:self.keyLabel];
//    self.keyLabel.font = [self.keyLabel.font fontWithSize:14.0];
//    [self.keyLabel setTextAlignment:NSTextAlignmentLeft];
}

- (void) initTextField
{
    self.stringValueField = [[UITextField alloc] initWithFrame:[self stringValueFieldFrame]];
    [self.contentView addSubview:self.stringValueField];
    [self.stringValueField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.stringValueField setTextAlignment:NSTextAlignmentCenter];
    [self.stringValueField setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.stringValueField setTextColor:rgb(242, 156, 180)];
}

- (void) initImageValueView
{
    self.imageValueView = [[UIImageView alloc] initWithFrame:[self imageValueViewFrame]];
    [self.contentView addSubview:self.imageValueView];
    [self.imageValueView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageValueView setClipsToBounds:YES];
    self.imageValueView.layer.cornerRadius = 10.0;
    [self.imageValueView setUserInteractionEnabled:YES];
    [self.imageValueView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet)]];
}

- (void) initDateValueView
{
    self.dateValuePicker = [[UIDatePicker alloc] initWithFrame:[self dateValuePickerFrame]];
    [self.contentView addSubview:self.dateValuePicker];
}

- (void) showActionSheet
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:self.key delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library",@"Take Photo", nil];
    [sheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex)
    {
        if(imagePickerController == nil)
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
        }
        imagePickerController.sourceType = buttonIndex ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        [self.delegate presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info: %@",info);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self imageValueChanged:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }];
    
}
- (void) setKey:(NSString *)key
{
    _key = key;
    if ([self.reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier])
    {
        self.stringValueField.placeholder = key;
    }
    else if([self.reuseIdentifier isEqualToString:SettingsTableCellImageValueIdentifier])
    {
        
    }
    
}

- (void) setValue:(id)value
{
    _value = value;
    if ([self.reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier])
    {
        self.stringValueField.text = value;
    }
    else if([self.reuseIdentifier isEqualToString:SettingsTableCellImageValueIdentifier])
    {
        self.imageValueView.image = value;
    }
}

- (void) textFieldValueChanged:(UITextField*)textField
{
    self.value = textField.text;
    [self.delegate valueChanged:self.value forKey:self.key];
}

- (void) imageValueChanged:(UIImage*)image
{
    self.value = image;
    [self.delegate valueChanged:self.value forKey:self.key];
}



@end
