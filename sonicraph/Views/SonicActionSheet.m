//
//  SonicActionSheet.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicActionSheet.h"
#import "SNCAPIManager.h"
#import "SNCFacebookManager.h"
#import <Social/Social.h>
#import "SNCAppDelegate.h"

#define ShareOnFacebook @"Share on Facebook"
#define ShareOnTwitter @"Share on Twitter"
#define CopyUrl @"Copy URL"
#define Delete @"Delete"
#define OpenDetails @"Open Details"
#define DeleteConfirmAlertViewTag 1121212

@implementation SonicActionSheet
{
    id<UIActionSheetDelegate> actualDelegate;
}

- (id)initWithSonic:(Sonic *)sonic
{
    NSString* destructiveButtonTitle = sonic.isMySonic ? Delete : nil;
    self = [self initWithTitle:sonic.tags
                      delegate:self
             cancelButtonTitle:@"Cancel"
        destructiveButtonTitle:destructiveButtonTitle
             otherButtonTitles:ShareOnFacebook,ShareOnTwitter,CopyUrl,OpenDetails, nil];
    if(self)
    {
        _sonic = sonic;
    }
    return self;
}

- (void)setDelegate:(id<UIActionSheetDelegate>)delegate
{
    [super setDelegate:self];
    if(delegate != self)
    {
        actualDelegate = delegate;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:Delete])
    {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"Delete"
                              message:@"Do you confirm to delete this sonic?"
                              delegate:self
                              cancelButtonTitle:@"Confirm"
                              otherButtonTitles:@"Cancel", nil];
        alert.tag = DeleteConfirmAlertViewTag;
        [alert show];
    }
    else if([buttonTitle isEqualToString:ShareOnFacebook])
    {
        [SNCFacebookManager shareSonicWithDialog:self.sonic withCompletionBlock:^(id object) {
            
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
    else if([buttonTitle isEqualToString:ShareOnTwitter])
    {
        SLComposeViewController* tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.sonic.owner.fullName];
        NSString* sonicPageLink = [NSString stringWithFormat:@"https://sonicraph.herokuapp.com/sonic?s=%@",self.sonic.sonicId];
        [tweetSheet addURL:[NSURL URLWithString:sonicPageLink]];
        SNCAppDelegate* delegate = [UIApplication sharedApplication].delegate;
        [delegate.tabbarController presentViewController:tweetSheet animated:YES completion:^{
            
        }];
    }
    
    if([actualDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
    {
        [actualDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actualDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
    {
        [actualDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([actualDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
    {
        [actualDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
    }
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if([actualDelegate respondsToSelector:@selector(actionSheetCancel:)])
    {
        [actualDelegate actionSheetCancel:actionSheet];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}


@end
