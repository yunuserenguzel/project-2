//
//  SNCPersonTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SNCPersonTableCell : UITableViewCell

@property (nonatomic) User* user;

@property UILabel* usernameLabel;

@end
