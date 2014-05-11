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
#import "UIViewController+CustomMethods.h"

@interface SNCHomeViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate,SNCHomeTableCellProtocol,OpenProfileProtocol,OpenSonicProtocol>
//@property UITableView* tableView;
//@property UIRefreshControl* refreshControl;

- (void) openSonicDetails:(Sonic*)sonic;
- (void) scrollToTop;
@end
