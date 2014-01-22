//
//  SNCSearchViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/22/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCSearchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property UITableView* userTableView;

@property UICollectionView* soncisCollectionView;

@property UITextField* searchField;
@property UIBarButtonItem* searchButton;

@end
