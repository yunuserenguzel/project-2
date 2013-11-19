//
//  SNCHomeTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonic.h"

#define HomeTableCellIdentifier @"HomeTableCellIdentifier"

@interface SNCHomeTableCell : UITableViewCell

@property (nonatomic) Sonic* sonic;

- (void) cellWonCenterOfTableView;

- (void) cellLostCenterOfTableView;

@end
