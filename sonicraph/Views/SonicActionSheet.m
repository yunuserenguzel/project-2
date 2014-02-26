//
//  SonicActionSheet.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicActionSheet.h"
#import "SNCAPIManager.h"

#define ShareOnFacebook @"Share on Facebook"
#define ShareOnTwitter @"Share on Twitter"
#define CopyUrl @"Copy URL"
#define OpenDetails @"Open Details"
#define DeleteConfirmAlertViewTag 1121212

@implementation SonicActionSheet
{
    id<UIActionSheetDelegate> actualDelegate;
}

- (id)initWithSonic:(Sonic *)sonic
{
    NSString* destructiveButtonTitle = sonic.isMySonic ? @"Delete" : nil;
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
    if(buttonIndex == 0){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Do you confirm to delete this sonic?" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
        alert.tag = DeleteConfirmAlertViewTag;
        [alert show];
    }
    
    if([actualDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
    {
        [actualDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }
    self.delegate = nil;
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

@end
