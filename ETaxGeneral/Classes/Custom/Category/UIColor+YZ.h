/************************************************************
 Class    : UIColor+YZ.h
 Describe : 自定义UIColor的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@interface UIColor (YZ)

// 根据16进制颜色代码生成颜色
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
