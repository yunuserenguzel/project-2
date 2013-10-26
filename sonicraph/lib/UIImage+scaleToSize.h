//
//  UIImage+scaleToSize.h
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/25/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(scaleToSize)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

- (UIImage*) cropForRect:(CGRect)rect;

@end
