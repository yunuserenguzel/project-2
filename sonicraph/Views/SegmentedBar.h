//
//  SegmentedBar.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/2/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedBar;

@protocol SegmentedBarDelegate

- (void) segmentedBar:(SegmentedBar*)segmentedBar selectedItemAtIndex:(NSInteger)index;

@end

@interface SegmentedBarItem : NSObject

@property UIImage* normalImage;
@property UIImage* selectedImage;
@property NSString* title;
@property NSString* subtitle;

+ (SegmentedBarItem*) itemWithNormalImage:(UIImage*) normalImage
                            selectedImage:(UIImage*) selectedImage
                                    title:(NSString*) title
                                 subtitle:(NSString*) subtitle;

@end

@interface SegmentedBar : UIView

@property (nonatomic) NSArray* items;
@property id<SegmentedBarDelegate> delegate;

- (void) setSelectedIndex:(NSInteger)index;

@end
