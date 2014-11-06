//
//  UIView+blurEffect.m
//  bleTerminal
//
//  Created by Ladvien on 11/5/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "UIView+blurEffect.h"

@implementation UIView (blurEffect)
-(UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
