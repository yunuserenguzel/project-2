//
//  SNCSettingsViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSettingsViewController.h"
#import "AuthenticationManager.h"
#import <MessageUI/MessageUI.h>

#define InviteFriendsActionSheetTag 781234

#define InviteViaEmail @"Invite Friends"
#define RateApp @"Rate This App"
#define SendFeedback @"Send Feedback"

#define FAQ @"FAQ"
#define LegalPrivacy @"Legal & Privacy"
#define AppVersion @"App Version"

@interface SNCSettingsViewController () <UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIActionSheetDelegate>

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
    self.navigationItem.title = @"Settings";
//    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setContentInset:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellStringValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellPasswordValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellDateValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellImageValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellGenderValueIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellButtonIdentifier];
    [self.tableView registerClass:[SettingsTableCell class] forCellReuseIdentifier:SettingsTableCellInfoIdentifier];
    [self prepareFields];
    [self.tableView reloadData];
}

-(void) prepareFields
{
    self.fields = [NSMutableArray new];
    
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:0] addObject:[SettingsField k:@"Change Password" sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:1] addObject:[SettingsField k:InviteViaEmail sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    [[self.fields objectAtIndex:1] addObject:[SettingsField k:RateApp sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    [[self.fields objectAtIndex:1] addObject:[SettingsField k:SendFeedback sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:2] addObject:[SettingsField k:FAQ sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    [[self.fields objectAtIndex:2] addObject:[SettingsField k:LegalPrivacy sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
    [[self.fields objectAtIndex:2] addObject:[SettingsField k:AppVersion sK:nil v:@"1.0" t:SettingsTableCellInfoIdentifier]];
    
    [self.fields addObject:[NSMutableArray new]];
    [[self.fields objectAtIndex:3] addObject:[SettingsField k:@"Logout" sK:nil v:nil t:SettingsTableCellButtonIdentifier]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return heightForIdentifier(SettingsTableCellButtonIdentifier);
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
    else if([settingsField.key isEqualToString:InviteViaEmail])
    {
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Invite friends" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"via E-mail",@"via Message", nil];
        sheet.tag = InviteFriendsActionSheetTag;
        [sheet showInView:self.view];
    }
    else if([settingsField.key isEqualToString:RateApp])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id828320730"]];
    }
    else if ([settingsField.key isEqualToString:SendFeedback])
    {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"Feedback | %@ | %@",[[AuthenticationManager sharedInstance] authenticatedUser].fullName, [[AuthenticationManager sharedInstance] authenticatedUser].userId]];
        [controller setToRecipients:@[@"feedback@sonicraph.com"]];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if([settingsField.key isEqualToString:FAQ])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sonicraph.com/faq"]];
    }
    else if([settingsField.key isEqualToString:LegalPrivacy])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sonicraph.com/legal"]];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == InviteFriendsActionSheetTag)
    {
        NSString* appUrl = @"http://itunes.apple.com/app/id828320730";
        if(buttonIndex == 0)
        {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Sonicraph "];
            [controller setMessageBody:[NSString stringWithFormat:@"Hello, check out this app %@",appUrl] isHTML:NO];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else if(buttonIndex == 1)
        {
            MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
            smsController.messageComposeDelegate = self;
            smsController.body = [NSString stringWithFormat:@"Hello, check out this app %@",appUrl];
            [self presentViewController:smsController animated:YES completion:nil];
        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 2)
    {
        UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
        [textView setText:@"About Us"];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTextContainerInset:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
        [textView setTextAlignment:NSTextAlignmentLeft];
        [textView setTextColor:TabbarNonActiveButtonTintColor];
        [textView setFont:[UIFont systemFontOfSize:16.0]];
        return textView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 2)
    {
        return 25.0;
    }
    return 0.0;
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
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
