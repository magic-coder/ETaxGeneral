/************************************************************
 Class    : YZButton.h
 Describe : 自定义文字、图片混合按钮样式，可进行图片、文字上、下、左、右排版布局
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-28
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@interface YZButton : UIButton

@property (nonatomic,assign) CGRect titleRect;
@property (nonatomic,assign) CGRect imageRect;

@end
