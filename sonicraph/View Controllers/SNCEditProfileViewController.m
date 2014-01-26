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
#import "SettingsTableCell.h"


@interface SettingsField : NSObject 
@property NSString* key;
@property id value;
@property NSString* type;
+ (SettingsField*) k:(NSString*)key v:(id)value t:(NSString*)type;

@end

@implementation SettingsField
+(SettingsField *)k:(NSString *)key v:(id)value t:(NSString *)type
{
    SettingsField* settingsField = [[SettingsField alloc] init];
    settingsField.key = key;
    settingsField.value = value;
    settingsField.type = type;
    return settingsField;
}
@end

@interface SNCEditProfileViewController ()

@property NSArray* fields;
@property User* user;
@property UIActivityIndicatorView* activityIndicator;
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
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellStringValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellPasswordValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellDateValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellImageValueIdentifier];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.tableView.frame];
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
    
    UIBarButtonItem* save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = save;
}

- (void) save
{
    
}

- (void) prepareFields
{
    [self.user getThumbnailProfileImageWithCompletionBlock:^(id object) {
        self.fields = @[
                        [SettingsField k:@"Photo" v:object t:SettingsTableCellImageValueIdentifier],
                        [SettingsField k:@"Name" v:self.user.fullName t:SettingsTableCellStringValueIdentifier],
                        [SettingsField k:@"Username" v:self.user.username t:SettingsTableCellStringValueIdentifier],
                        [SettingsField k:@"Location" v:self.user.location t:SettingsTableCellStringValueIdentifier],
                        [SettingsField k:@"Website" v:self.user.website t:SettingsTableCellStringValueIdentifier]
                        ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fields ? self.fields.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsField* settingsField = [self.fields objectAtIndex:indexPath.row];
    NSString* identifier = settingsField.type;
    SettingsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setKey:settingsField.key];
    [cell setValue:settingsField.value];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fields) {
        SettingsField* field = [self.fields objectAtIndex:indexPath.row];
        return heightForIdentifier(field.type);
    }
    else {
        return 44.0;
    }
}

@end
