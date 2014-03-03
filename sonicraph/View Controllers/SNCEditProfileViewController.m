//
//  SNCEditProfileViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCEditProfileViewController.h"
#import "SNCAPIManager.h"
#import "AuthenticationManager.h"

@interface SettingsField : NSObject 
@property NSString* key;
@property NSString* serverKey;
@property id value;
@property NSString* type;
+ (SettingsField*) k:(NSString*)key sK:(NSString*)serverKey v:(id)value t:(NSString*)type;

@end

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

@interface SNCEditProfileViewController ()

@property NSMutableArray* fields1;
@property NSMutableArray* fields2;
@property NSMutableDictionary* changedFields;
@property User* user;
@property UIActivityIndicatorView* activityIndicator;
@property UIBarButtonItem* saveButton;
@property UIBarButtonItem* cancelButton;
@end

@implementation SNCEditProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.changedFields = [NSMutableDictionary new];
    [self.tableView setContentInset:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellStringValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellPasswordValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellDateValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellImageValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellGenderValueIdentifier];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [self.tableView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [SNCAPIManager
     checkIsTokenValid:[[AuthenticationManager sharedInstance] token]
     withCompletionBlock:^(User *user, NSString *token) {
         self.user = user;
         [self prepareFields];
         [self.activityIndicator stopAnimating];
    } andErrorBlock:^(NSError *error) {
        [self.activityIndicator stopAnimating];
    }];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    UILabel* beCoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 472, 320.0, 33.0)];
    [beCoolLabel setText:@"Be Cool :)"];
    [beCoolLabel setFont:[UIFont systemFontOfSize:14.0]];
    [beCoolLabel setTextColor:self.tableView.separatorColor];
    [beCoolLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tableView addSubview:beCoolLabel];
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) save
{
    [self.view endEditing:YES];
    if(self.changedFields.count > 0)
    {
        [self.tableView setUserInteractionEnabled:NO];
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator sizeToFit];
        [activityIndicator startAnimating];
        [SNCAPIManager editProfileWithFields:self.changedFields withCompletionBlock:^(User *user, NSString *token) {
            self.changedFields = [NSMutableDictionary new];
            [self.tableView setUserInteractionEnabled:YES];
            self.navigationItem.rightBarButtonItem = self.saveButton;
            [activityIndicator stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        } andErrorBlock:^(NSError *error) {
            if(error.code == APIErrorCodeUsernameExist)
            {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This username already exists. Choose a different username." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
            [self.tableView setUserInteractionEnabled:YES];
            self.navigationItem.rightBarButtonItem = self.saveButton;
            [activityIndicator stopAnimating];
        }];
    }
}

- (void) prepareFields
{
    SettingsField* imageSettings = [SettingsField k:@"Photo" sK:@"profile_image" v:nil t:SettingsTableCellImageValueIdentifier];
    self.fields1 = [NSMutableArray new];
    [self.fields1 addObject:imageSettings];
    [self.fields1 addObject:[SettingsField k:@"Name" sK:@"fullname" v:self.user.fullName t:SettingsTableCellStringValueIdentifier]];
    [self.fields1 addObject:[SettingsField k:@"Username" sK:@"username" v:self.user.username t:SettingsTableCellStringValueIdentifier]];
    [self.fields1 addObject:[SettingsField k:@"Location" sK:@"location" v:self.user.location t:SettingsTableCellStringValueIdentifier]];
    [self.fields1 addObject:[SettingsField k:@"Website" sK:@"website" v:self.user.website t:SettingsTableCellStringValueIdentifier]];
    self.fields2 = [NSMutableArray new];
    [self.fields2 addObject:[SettingsField k:@"MM / DD / YYYY" sK:@"date_of_birth" v:self.user.dateOfBirth t:SettingsTableCellDateValueIdentifier]];
    [self.fields2 addObject:[SettingsField k:@"Gender" sK:@"gender" v:self.user.gender t:SettingsTableCellGenderValueIdentifier]];
    [self.tableView reloadData];
    [self.user getThumbnailProfileImageWithCompletionBlock:^(id object) {
        imageSettings.value = object;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 33.0)];
        [label setText:@"Birthday and Gender"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:self.tableView.separatorColor];
        [label setFont:[UIFont systemFontOfSize:14.0]];
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 33.0;
    }
    return 1.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.fields1.count : self.fields2.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsField* settingsField;
    if(indexPath.section == 0)
    {
        settingsField = [self.fields1 objectAtIndex:indexPath.row];
    }
    else
    {
        settingsField = [self.fields2 objectAtIndex:indexPath.row];
    }
    NSString* identifier = settingsField.type;
    
    SettingsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setKey:settingsField.key];
    [cell setValue:settingsField.value];
    [cell setDelegate:self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0 && self.fields1)
    {
        SettingsField* field = [self.fields1 objectAtIndex:indexPath.row];
        return heightForIdentifier(field.type);
    }
    else if(indexPath.section == 1 && self.fields2)
    {
        SettingsField* field = [self.fields2 objectAtIndex:indexPath.row];
        return heightForIdentifier(field.type);
    }
    else
    {
        return 44.0;
    }
}

- (void) valueChanged:(id)value forKey:(NSString *)key
{
    for (SettingsField* field in [self.fields1 arrayByAddingObjectsFromArray:self.fields2])
    {
        if([field.key isEqualToString:key])
        {
            field.value = value;
            [self.changedFields setObject:value forKey:field.serverKey];
            break;
        }
    }
}


@end
