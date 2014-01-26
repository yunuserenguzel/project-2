//
//  SNCSearchViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/22/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCSearchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource,UICollectionViewDelegate>

@property UITableView* userTableView;

@property UICollectionView* sonicsCollectionView;

@property UISearchBar* searchBar;

@property UISegmentedControl* segmentControl;

@end
