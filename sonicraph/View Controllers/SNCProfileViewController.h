//
//  SNCProfileViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeDefs.h"
#import "User.h"
#import "ProfileHeaderView.h"
#import "SNCHomeTableCell.h"

@interface SNCProfileViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate,SNCHomeTableCellProtocol>


@property (nonatomic) User* user;
@property ProfileHeaderView* profileHeaderView;


@property UITableView* sonicListTableView;

@property UICollectionView* sonicCollectionView;
@property UICollectionViewFlowLayout* sonicCollectionViewFlowLayout;

@end
