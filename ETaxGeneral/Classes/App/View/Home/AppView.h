/************************************************************
 Class    : AppView.h
 Describe : 自定义应用列表视样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class AppView, AppModelItem;

@protocol AppViewDelegate <NSObject>

@optional
- (void)appViewClick:(AppView *)appView;// 点击代理方法

@end

@interface AppView : UIView

@property (nonatomic, strong) UILabel *titleLabel;      // 标签（外部需要使用，所以定义在头文件中）
@property (nonatomic, strong) AppModelItem *item;

@property (nonatomic, weak) id<AppViewDelegate> delegate;

@end
