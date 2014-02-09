//
//  SNCFollowerFollowingViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/5/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "SNCPersonTableCell.h"
#import "TypeDefs.h"

@interface SNCFollowerFollowingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SNCPersonFollowableTableCellProtocol,OpenProfileProtocol>

@property (nonatomic) User* user;

@property (nonatomic) BOOL shouldShowFollowers;

@property UITableView* tableView;

@property UISegmentedControl* segmentedControl;

@end