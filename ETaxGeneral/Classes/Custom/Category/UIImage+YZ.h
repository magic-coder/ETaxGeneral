/************************************************************
 Class    : UIImage+YZ.h
 Describe : 自定义UIImage的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@interface UIImage (YZ)

// 根据视图的大小来计算图片的大小
+ (UIImage *)imageNamed:(NSString *)name scaleToSize:(CGSize)size;

// 根据指定大小裁剪图片
+ (UIImage *)clipImage:(UIImage *)image rect:(CGRect)rect;

// 根据颜色创建图片
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
