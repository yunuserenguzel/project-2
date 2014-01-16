//
//  SNCHomeViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/12/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCHomeTableCell.h"
#import "TypeDefs.h"
@interface SNCHomeViewController : UITableViewController <UIScrollViewDelegate,SNCHomeTableCellProtocol,OpenProfileProtocol>

@end
