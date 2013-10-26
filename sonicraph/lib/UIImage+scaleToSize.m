//
//  UIImage+scaleToSize.m
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 8/25/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "UIImage+scaleToSize.h"

@implementation UIImage (scaleToSize)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage* sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else {
            if (widthFactor < heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        //        NSLog(@"could not scale image");
        return nil;
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    UIImage* result = [[UIImage alloc] initWithCGImage:newImage.CGImage];
    return result;
}

- (UIImage*) cropForRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,2.0);
    CGFloat x = -rect.origin.x;
    CGFloat y = -rect.origin.y;
    [self drawInRect:CGRectMake(x, y, self.size.width, self.size.height)];
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();

//    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
//    UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
    return croppedImage;
}

@end
