/************************************************************
 Class    : UINavigationBar+YZ.h
 Describe : 自定义UINavigationBar的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 LastDate : 2018-03-06
 Version  : 2.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@interface UINavigationBar (YZ)

// version 1.0：封装导航栏自定义方法（废弃）
/*
- (void)yz_setBackgroundColor:(UIColor *)backgroundColor;
- (void)yz_setElementsAlpha:(CGFloat)alpha;
- (void)yz_setTranslationY:(CGFloat)translationY;
- (void)yz_reset;
*/

// version 2.0：封装导航栏自定义方法

/**
 * 初始化导航栏，隐藏导航栏下的横线，背景色置空
 */
- (void)yz_initialize;

/**
 * @param color 最终显示的颜色
 * @param scrollView 当前滑动的视图
 * @param value 滑动临界值，根据情况设定
 */
- (void)yz_changeColor:(UIColor *)color WithScrollView:(UIScrollView *)scrollView AndValue:(CGFloat)value;

/**
 * 还原导航栏
 */
- (void)yz_reset;

@end
