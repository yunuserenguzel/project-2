//
//  SonicPresenter.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 25/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicPresenter.h"
#import "SNCAppDelegate.h"
#import "SNCAPIManager.h"

@interface SonicPresenter ()

@property SNCNavigationViewController* navigationController;
@property SNCSonicViewController* sonicViewController;

@end

static SonicPresenter* sharedInstance = nil;

@implementation SonicPresenter

+ (SonicPresenter *)sharedInstance
{
    if(sharedInstance == nil)
    {
        sharedInstance = [[SonicPresenter alloc] init];
    }
    return sharedInstance;
}

- (void) presentSonicWithId:(NSString *)sonicId
{
    if(![self.sonicId isEqualToString:sonicId])
    {
        [self dismissViewControllers];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.sonicViewController = [storyboard instantiateViewControllerWithIdentifier:@"SonicViewController"];
        self.navigationController = [[SNCNavigationViewController alloc] init];
        [self.navigationController pushViewController:self.sonicViewController animated:NO];
        
        UINavigationItem* item = [self.navigationController.navigationBar.items objectAtIndex:0];
        [item setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewControllers)]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[SNCAppDelegate sharedInstance] tabbarController] presentViewController:self.navigationController animated:YES completion:nil];
        });
        [SNCAPIManager getSonicWithId:sonicId withCompletionBlock:^(id object) {
            [self.sonicViewController setSonic:object];
        } andErrorBlock:^(NSError *error) {
            
        }];
    }
}

- (void) dismissViewControllers
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.navigationController = nil;
        self.sonicViewController = nil;
    }];
}

@end
