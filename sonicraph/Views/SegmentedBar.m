//
//  SegmentedBar.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/2/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SegmentedBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation SegmentedBarItem


+ (SegmentedBarItem*) itemWithNormalImage:(UIImage*) normalImage
                            selectedImage:(UIImage*) selectedImage
                                    title:(NSString*) title
                                 subtitle:(NSString*) subtitle
{
    SegmentedBarItem* item = [[SegmentedBarItem alloc] init];
    item.normalImage = normalImage;
    item.selectedImage = selectedImage;
    item.title = title;
    item.subtitle = subtitle;
    return item;
}

@end


@implementation SegmentedBar
{
    BOOL isInitCalled;
    NSArray* buttons;
    
}

- (id)init
{
    if(self = [super init]){
        [self initViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    if(isInitCalled){
        return;
    } else {
        isInitCalled = YES;
    }
//    [self setBackgroundColor:[UIColor whiteColor]];
    [self setUserInteractionEnabled:YES];
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
}
- (void)setItems:(NSArray *)items
{
    _items = items;
    [self organizeForItems];
}

- (void) organizeForItems
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* view = obj;
        [view removeFromSuperview];
    }];
    NSMutableArray* tempButtonsArray = [NSMutableArray new];
    CGFloat unitWidth = self.frame.size.width / (CGFloat) self.items.count;
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton* button = [self buttonForSegmentedBarItem:obj];
        CGRect frame = CGRectMake(0.0, 0.0, 0.0, self.frame.size.height);
        frame.origin.x = unitWidth * idx;
        frame.size.width = unitWidth;
        [button setFrame:frame];
        [self addSubview:button];
        [tempButtonsArray addObject:button];
        if(idx < self.items.count - 1){
            UIImageView* seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SegmentedButtonBarSeperator.png"]];
            [seperator setContentMode:UIViewContentModeCenter];
            frame.size.width = 1.0;
            frame.origin.x = unitWidth * (idx+1);
            [seperator setFrame:frame];
            [self addSubview:seperator];
        }
    }];
    buttons = [NSArray arrayWithArray:tempButtonsArray];
}

- (UIButton*) buttonForSegmentedBarItem:(SegmentedBarItem*)segmentedBarItem
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:segmentedBarItem.normalImage forState:UIControlStateNormal];
    [button setImage:segmentedBarItem.selectedImage forState:UIControlStateSelected];
    [button setTitle:[NSString stringWithFormat:@"%@\n%@",segmentedBarItem.title,segmentedBarItem.subtitle] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setNumberOfLines:0];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)];
    [[button titleLabel] setFont:[[button.titleLabel font] fontWithSize:11.0]];
    
    return button;
}

- (void)setSelectedIndex:(NSInteger)index
{
    for (int i=0; i< buttons.count; i++) {
        UIButton* button = [buttons objectAtIndex:i];
        [button setSelected:NO];
        if(i == index){
            [button setSelected:YES];
        }
    }
    if(self.delegate){
        [self.delegate segmentedBar:self selectedItemAtIndex:index];
    }
}

- (void) buttonClicked:(UIButton*) selectedButton
{
    int selectedIndex = -1;
    
    for (int i=0; i< buttons.count; i++) {
        UIButton* button = [buttons objectAtIndex:i];
        [button setSelected:NO];
        if(selectedButton == button){
            selectedIndex = i;
        }
    }

    [selectedButton setSelected:YES];
    if(self.delegate && selectedIndex > -1 ){
        [self.delegate segmentedBar:self selectedItemAtIndex:selectedIndex];
    }
}

@end
