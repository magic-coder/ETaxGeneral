/************************************************************
 Class    : MenuView.h
 Describe : 左侧滑动菜单底层视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate <NSObject>

- (void)willAppear;    // 左滑菜单即将显示方法
- (void)willDisappear;  // 左滑菜单即将消失方法

@end

@interface MenuView : UIView

// 代理方法
@property (nonatomic ,weak) id <MenuViewDelegate> delegate;

+ (instancetype)MenuViewWithDependencyView:(UIView *)dependencyView MenuView:(UIView *)leftmenuView isShowCoverView:(BOOL)isCover;

/**
 *  初始化方法
 *
 *  @param dependencyView 传入需要滑出菜单的控制器的view
 *  @param leftmenuView   传入需要显示的菜单的view
 *  @param isCover        bool值，是否有右边遮挡的阴影
 *
 *  @return self
 */
- (instancetype)initWithDependencyView:(UIView *)dependencyView MenuView:(UIView *)leftmenuView isShowCoverView:(BOOL)isCover;
    
/**
 * 展开菜单，可放进点击事件内
 */
-(void)show;

/**
 * 关闭菜单不带动画效果
 */
- (void)hidenWithoutAnimation;

/**
 * 关闭菜单带动画效果
 */
- (void)hidenWithAnimation;

@end

