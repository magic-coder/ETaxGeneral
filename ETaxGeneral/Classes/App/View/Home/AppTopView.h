/************************************************************
 Class    : AppTopView.h
 Describe : 自定义应用界面顶部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@protocol AppTopViewDelegate <NSObject>

@optional
- (void)appTopViewBtnClick:(UIButton *)sender;// 点击代理方法

@end

@interface AppTopView : UIView

@property (nonatomic, weak) id<AppTopViewDelegate> delegate;

@end
