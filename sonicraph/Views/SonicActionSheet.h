//
//  SonicActionSheet.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 26/02/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

#define ShareOnFacebook @"Share on Facebook"
#define ShareOnTwitter @"Share on Twitter"
#define ShareWithWhatsapp @"Share with Whatsapp"
#define CopyUrl @"Copy URL"
#define Delete @"Delete"
#define OpenDetails @"Open Details"

@interface SonicActionSheet : UIActionSheet <UIActionSheetDelegate, UIAlertViewDelegate>

@property (readonly) Sonic* sonic;

- (id) initWithSonic:(Sonic*)sonic includeOpenDetails:(BOOL)includeOpenDetails;

@end
