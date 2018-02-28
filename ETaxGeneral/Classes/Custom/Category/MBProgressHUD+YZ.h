/************************************************************
 Class    : MBProgressHUD+YZ.h
 Describe : 自定义MBProgressHUD的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MBProgressHUD.h"

// 自定义加载框展示方式枚举型
typedef NS_ENUM (NSInteger, YZProgressHUDMode) {
    YZProgressHUDModeEvent, // 屏蔽事件，禁止所有用户操作
    YZProgressHUDModeLock,  // 锁定方式不自动消失
    YZProgressHUDModeShow   // 提示方式自动消失
};

@interface MBProgressHUD (YZ)

// 显示提示框
+ (void)showHUDView:(UIView *)view text:(NSString *)text progressHUDMode:(YZProgressHUDMode)progressHUDMode;

// 隐藏提示框
+ (void)hiddenHUDView:(UIView *)view;

@end
