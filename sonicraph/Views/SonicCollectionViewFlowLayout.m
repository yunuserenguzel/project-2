//
//  SonicCollectionViewFlowLayout.m
//  Sonicraph
//
//  Created by Yunus Eren Guzel on 08/05/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SonicCollectionViewFlowLayout.h"

#import "Configurations.h"

@implementation SonicCollectionViewFlowLayout

- (id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    [self setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self setItemSize:SonicCollectionViewCellSize];
    [self setMinimumLineSpacing:10.0];
    [self setMinimumInteritemSpacing:10.0];
    [self setSectionInset:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
}
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return nil;
}

@end
