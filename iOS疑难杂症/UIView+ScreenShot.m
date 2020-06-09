//
//  UIView+ScreenShot.m
//  MojiWeather
//
//  Created by wei.jiang on 2020/6/9.
//  Copyright © 2020 Moji Fengyun Technology Co., Ltd. All rights reserved.
//

#import "UIView+ScreenShot.h"
#import <objc/runtime.h>

@implementation UIView (ScreenShot)

- (UIImage *)screenShot {
    if (self && self.frame.size.height && self.frame.size.width) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    } else {
        return nil;
    }
}


@end
