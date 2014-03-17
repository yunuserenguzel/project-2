//
//  SNCSettingsViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSettingsViewController.h"
#import "AuthenticationManager.h"
@interface SNCSettingsViewController () <UIAlertViewDelegate>

@property NSMutableArray* fields;

@end

@implementation SNCSettingsViewController

- (CGRect) logoutButtonFrame
{
    return CGRectMake(0.0, 100.0, 320.0, 44.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellStringValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellPasswordValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellDateValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellImageValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellGenderValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellButtonIdentifier];
    [self prepareFields];
    [self.tableView reloadData];
}

-(void) prepareFields
{
    self.fields = [NSMutableArray new];
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:0] addObject:[SettingsField k:@"Change Password" sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    [[self.fields objectAtIndex:0] addObject:[SettingsField k:@"Logout" sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:1] addObject:[SettingsField k:@"About Us" sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
}

- (void) logout
{
    [[[UIAlertView alloc]
      initWithTitle:@"Logout"
      message:@"Do you want to logout?"
      delegate:self
      cancelButtonTitle:@"Cancel"
      otherButtonTitles:@"Logout", nil]
     show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
    } else {
        [[AuthenticationManager sharedInstance] logout];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fields ? self.fields.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fields objectAtIndex:section] ? [[self.fields objectAtIndex:section] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsField* settingsField = [[self.fields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString* identifier = settingsField.type;
    
    SettingsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setKey:settingsField.key];
    [cell setValue:settingsField.value];
    [cell setDelegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsField* settingsField = [[self.fields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([settingsField.key isEqualToString:@"Logout"])
    {
        [self logout];
    }
    else if([settingsField.key isEqualToString:@"Change Password"])
    {
        [self performSegueWithIdentifier:ChangePasswordSegue sender:self];
    }
    else if([settingsField.key isEqualToString:@"About Us"])
    {
        [self performSegueWithIdentifier:AboutUsSegue sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)valueChanged:(id)value forKey:(NSString *)string
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
