//
//  SNCProfileViewController.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeDefs.h"

@interface SNCProfileViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property UICollectionView* sonicCollectionView;
@property UICollectionViewFlowLayout* sonicCollectionViewFlowLayout;
@end
