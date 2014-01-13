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

@property (nonatomic) UIImage* normalImage;
@property (nonatomic) UIImage* selectedImage;
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* subtitle;
@property (nonatomic) UIButton* button;

+ (SegmentedBarItem*) itemWithNormalImage:(UIImage*) normalImage
                            selectedImage:(UIImage*) selectedImage
                                    title:(NSString*) title
                                 subtitle:(NSString*) subtitle;

+ (NSString*) buttonTextWithTitle:(NSString*)title andSubTitle:(NSString*)subtitle;

@end

@interface SegmentedBar : UIView

@property (nonatomic) NSArray* items;
@property id<SegmentedBarDelegate> delegate;

- (void) setSelectedIndex:(NSInteger)index;

@end
