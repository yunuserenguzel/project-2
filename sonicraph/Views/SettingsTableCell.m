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
#import "Configurations.h"
#import "UIButton+StateProperties.h"


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

@property UITextField* monthField;
@property UITextField* dayField;
@property UITextField* yearField;

@property UIButton* maleButton;
@property UIButton* femaleButton;

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

- (CGRect) monthFieldFrame
{
    return CGRectMake(96.0, 0.0, 44.0, 44.0);
}

- (CGRect) dayFieldFrame
{
    return CGRectMake(8.0 + [self monthFieldFrame].origin.x + [self monthFieldFrame].size.width, 0.0, 44.0, 44.0);
}

- (CGRect) yearFieldFrame
{
    return CGRectMake([self dayFieldFrame].origin.x + [self dayFieldFrame].size.width, 0.0, 66.0, 44.0);
}

- (CGRect) maleButtonFrame
{
    return CGRectMake(80.0, 0.0, 80.0, 44.0);
}

- (CGRect) femaleButtonFrame
{
    return CGRectMake(160.0, 0.0, 80.0, 44.0);
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
        else if([reuseIdentifier isEqualToString:SettingsTableCellGenderValueIdentifier])
        {
            [self initGenderValueView];
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
    [self.stringValueField setTextColor:LightPinkTextColor];
    [self.stringValueField setValue:UITextFieldPlaceholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (void) initImageValueView
{
    UIImageView* baseImageView = [[UIImageView alloc] initWithFrame:[self imageValueViewFrame]];
    baseImageView.image = [UIImage imageNamed:@"EditProfilePhotoBase.png"];
    [self.contentView addSubview:baseImageView];
    
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
    
    self.monthField = [[UITextField alloc] initWithFrame:[self monthFieldFrame]];
    [self.monthField setPlaceholder:@"mm"];
    
    self.dayField = [[UITextField alloc] initWithFrame:[self dayFieldFrame]];
    [self.dayField setPlaceholder:@"dd"];
    
    self.yearField = [[UITextField alloc] initWithFrame:[self yearFieldFrame]];
    [self.yearField setPlaceholder:@"yyyy"];
    
    for(UITextField* textField in @[self.monthField, self.dayField, self.yearField])
    {
        [textField setTextAlignment:NSTextAlignmentLeft];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [self.contentView addSubview:textField];
        [textField setFont:[UIFont boldSystemFontOfSize:18.0]];
        [textField setTextColor:LightPinkTextColor];
        [textField setDelegate:self];
        [textField setTintColor:LightPinkTextColor];
        [textField addTarget:self action:@selector(textFieldEdited:) forControlEvents:UIControlEventEditingChanged];
        [textField setValue:UITextFieldPlaceholderColor forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (void) initGenderValueView
{
    self.maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.maleButton setFrame:[self maleButtonFrame]];
    [self.maleButton setTitle:@"Male" forState:UIControlStateNormal];
    
    self.femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.femaleButton setFrame:[self femaleButtonFrame]];
    [self.femaleButton setTitle:@"Female" forState:UIControlStateNormal];
    
    for (UIButton* button in @[self.maleButton, self.femaleButton]) {
        [self.contentView addSubview:button];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        
        [button setTitleColor:UITextFieldPlaceholderColor forState:UIControlStateNormal];
        [button setTitleColor:LightPinkTextColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(genderButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) genderButtonTapped:(UIButton*)button
{
    [self.maleButton setSelected:NO];
    [self.femaleButton setSelected:NO];
    [button setSelected:YES];
    NSString* value = self.maleButton ? @"male" : @"female";
    [self.delegate valueChanged:value forKey:self.key];
}

- (void) textFieldEdited:(UITextField*)textField
{
    if(textField == self.monthField)
    {
        if(textField.text.length >= 2)
        {
            [self.dayField becomeFirstResponder];
        }
    }
    else if(textField == self.dayField)
    {
        if(textField.text.length >= 2)
        {
            [self.yearField becomeFirstResponder];
        }
    }
    [self checkDateValueIsReady];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(string.length == 0)
    {
        return YES;
    }
    NSString* resultingText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField == self.dayField || textField == self.monthField)
    {
        if ([textField.text length] >= 2) {
            textField.text = [textField.text substringToIndex:2];
            return NO;
        }
        if(textField == self.dayField && [resultingText intValue] > 31)
        {
            return NO;
        }
        else if(textField == self.monthField && [resultingText intValue] > 12)
        {
            return NO;
        }
    }
    else if(textField == self.yearField)
    {
        if([textField.text length] >= 4)
        {
            textField.text = [textField.text substringToIndex:4];
            return NO;
        }
    }
    return YES;
}

- (void) checkDateValueIsReady
{
    if(self.monthField.text.length > 0 && self.dayField.text.length > 0 && self.yearField.text.length == 4)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString* dateString = [NSString stringWithFormat:@"%@-%@-%@",self.yearField.text,self.monthField.text,self.dayField.text];
        NSDate *date = [dateFormat dateFromString:dateString];
        [self.delegate valueChanged:date forKey:self.key];
    }
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
        [self.stringValueField setValue:UITextFieldPlaceholderColor forKeyPath:@"_placeholderLabel.textColor"];
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
    else if([self.reuseIdentifier isEqualToString:SettingsTableCellDateValueIdentifier])
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:value];
        [self.dayField setText:[NSString stringWithFormat:@"%d",components.day]];
        [self.monthField setText:[NSString stringWithFormat:@"%d",components.month]];
        [self.yearField setText:[NSString stringWithFormat:@"%d",components.year]];
    }
    else if([self.reuseIdentifier isEqualToString:SettingsTableCellGenderValueIdentifier])
    {
        if([value isEqualToString:@"male"])
        {
            [self.maleButton setSelected:YES];
        }
        else if([value isEqualToString:@"female"])
        {
            [self.femaleButton setSelected:YES];
        }
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
