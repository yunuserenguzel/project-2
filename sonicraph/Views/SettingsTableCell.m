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


@implementation SettingsField
+(SettingsField *)k:(NSString *)key sK:(NSString*)serverKey v:(id)value t:(NSString *)type
{
    SettingsField* settingsField = [[SettingsField alloc] init];
    settingsField.key = key;
    settingsField.serverKey = serverKey;
    settingsField.value = value;
    settingsField.type = type;
    return settingsField;
}
@end

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

@property UIButton* dateOfBirthButton;

@end


@implementation SettingsTableCell
{
    UIImagePickerController* imagePickerController;
//    GKImagePicker* imagePicker;
    UIWindow* window;
    UIDatePicker* datePicker;
}

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
        else if([reuseIdentifier isEqualToString:SettingsTableCellButtonIdentifier])
        {
            [self initButtonView];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void) initViews
{
    
}

- (void) initButtonView
{
    
}

- (void) initTextField
{
    self.stringValueField = [[UITextField alloc] initWithFrame:[self stringValueFieldFrame]];
    self.stringValueField.delegate = self;
    [self.contentView addSubview:self.stringValueField];
    [self.stringValueField setTextAlignment:NSTextAlignmentCenter];
    [self.stringValueField setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.stringValueField setTextColor:LightPinkTextColor];
    [self.stringValueField setValue:UITextFieldPlaceholderColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.stringValueField setReturnKeyType:UIReturnKeyDone];
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

    self.dateOfBirthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dateOfBirthButton setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [self.dateOfBirthButton addTarget:self action:@selector(dateCellTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.dateOfBirthButton setTitleColor:UITextFieldPlaceholderColor forState:UIControlStateNormal];
    [self.dateOfBirthButton setTitleColor:LightPinkTextColor forState:UIControlStateSelected];
    [self.dateOfBirthButton setTitle:@"mm / dd / yyyy" forState:UIControlStateNormal];
    [self.dateOfBirthButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.contentView addSubview:self.dateOfBirthButton];
}

- (void) dateCellTapped
{
    UIViewController* viewController = [[UIViewController alloc] init];
    [viewController.view setUserInteractionEnabled:YES];
    
    datePicker = [[UIDatePicker alloc] init];
    if([self.value isKindOfClass:[NSDate class]])
    {
        [datePicker setDate:self.value animated:YES];
    }
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setFrame:CGRectMake(0.0, viewController.view.frame.size.height-datePicker.frame.size.height, 320.0, datePicker.frame.size.height)];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setTintColor:LightPinkTextColor];
    [viewController.view addSubview:datePicker];
    
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, datePicker.frame.origin.y - 44.0, 320.0, 44.0)];
    [viewController.view addSubview:view];
    [view setBackgroundColor:[UIColor whiteColor]];
    UIView* borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
    [borderView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [borderView.layer setBorderWidth:1.0];
    [view addSubview:borderView];
    
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:LightPinkTextColor forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [doneButton setFrame:CGRectMake(200.0, datePicker.frame.origin.y - 44.0, 120.0, 44.0)];
    [doneButton addTarget:self action:@selector(donePickingDate) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:doneButton];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UITextFieldPlaceholderColor forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0.0, datePicker.frame.origin.y - 44.0, 120.0, 44.0)];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [cancelButton addTarget:self action:@selector(closeDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:cancelButton];
    
    window = [[UIWindow alloc] init];
    [window setRootViewController:viewController];
    [window setUserInteractionEnabled:YES];
    [window setBounds:[[UIScreen mainScreen] bounds]];
    [window setFrame:[[UIScreen mainScreen] bounds]];
    [window setWindowLevel:UIWindowLevelAlert+1];
    [window makeKeyAndVisible];
    
    viewController.view.transform = CGAffineTransformMakeTranslation(0.0, viewController.view.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        viewController.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }];
    
}

- (void) closeDatePicker
{
    [UIView animateWithDuration:0.5 animations:^{
        window.rootViewController.view.transform = CGAffineTransformMakeTranslation(0.0, window.rootViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        [window resignKeyWindow];
        window = nil;
    }];
}

- (void) donePickingDate
{
    self.value = datePicker.date;
    [self.delegate valueChanged:self.value forKey:self.key];
    [self closeDatePicker];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField == self.stringValueField)
    {
        self.value = [textField.text copy];
        [self.delegate valueChanged:self.value forKey:self.key];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(string.length == 0 )
    {
        return YES;
    }
    NSLog(@"string:%@ range: %d,%d",string,range.location,range.length);
    NSString* resultingText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.key isEqualToString:@"Username"] && textField == self.stringValueField)
    {
        NSString *searchedString = resultingText;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"[a-zA-Z][a-zA-Z0-9]*";
        NSError  *error = nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSRange range = [regex rangeOfFirstMatchInString:searchedString options:0 range: searchedRange];
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (range.length == searchedRange.length) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
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
            imagePickerController.allowsEditing = YES;
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
        [self imageValueChanged:[info objectForKey:UIImagePickerControllerEditedImage]];
    }];
    
}
- (void) setKey:(NSString *)key
{
    _key = key;
    if ([self.reuseIdentifier isEqualToString:SettingsTableCellStringValueIdentifier])
    {
        self.stringValueField.placeholder = key;
        [self.stringValueField setValue:UITextFieldPlaceholderColor forKeyPath:@"_placeholderLabel.textColor"];
        if ([key isEqualToString:@"Username"] || [key isEqualToString:@"Website"])
        {
            [self.stringValueField setSpellCheckingType:UITextSpellCheckingTypeNo];
            [self.stringValueField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        }
        else if([key isEqualToString:@"Name"] || [key isEqualToString:@"Location"])
        {
            [self.stringValueField setSpellCheckingType:UITextSpellCheckingTypeNo];
            [self.stringValueField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        }
        if([key isEqualToString:@"Website"])
        {
            [self.stringValueField setKeyboardType:UIKeyboardTypeURL];
        }
        else
        {
            [self.stringValueField setKeyboardType:UIKeyboardTypeDefault];
        }
    }
    else if([self.reuseIdentifier isEqualToString:SettingsTableCellButtonIdentifier])
    {
        [self.textLabel setText:key];
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
        if(value)
        {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:value];
            NSString* titleString = [NSString stringWithFormat:@"%d / %d / %d",components.month,components.day,components.year];
            [self.dateOfBirthButton setTitle:titleString forState:UIControlStateSelected];
            [self.dateOfBirthButton setSelected:YES];
        }
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

- (void) imageValueChanged:(UIImage*)image
{
    self.value = image;
    [self.delegate valueChanged:self.value forKey:self.key];
}



@end
