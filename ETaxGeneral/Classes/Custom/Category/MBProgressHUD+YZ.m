/************************************************************
 Class    : MBProgressHUD+YZ.m
 Describe : 自定义MBProgressHUD的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MBProgressHUD+YZ.h"

@implementation MBProgressHUD (YZ)

#pragma mark - 显示提示框
+ (void)showHUDView:(UIView *)view text:(NSString *)text progressHUDMode:(YZProgressHUDMode)progressHUDMode {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.bezelView.backgroundColor = [UIColor blackColor];   // 设置背景颜色
    hud.contentColor = [UIColor whiteColor];    // 设置字体颜色
    hud.label.text = text;
    
    if(YZProgressHUDModeEvent == progressHUDMode) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        hud.square = YES;// 设置成正方形
    }
    
    if(YZProgressHUDModeLock == progressHUDMode) {
        hud.square = YES;// 设置成正方形
    }
    
    float fontSize = 15.0f;
    if(DEVICE_SCREEN_INCH_IPAD){
        fontSize = 24.0f;
    }
    
    if(YZProgressHUDModeShow == progressHUDMode) {
        hud.label.font = [UIFont systemFontOfSize:fontSize];
        hud.mode = MBProgressHUDModeText;// 设置样式为只显示文字
        [hud hideAnimated:YES afterDelay:1.7f];// 1.7秒后自动消失
    }
    
}

#pragma mark - 隐藏提示框
+ (void)hiddenHUDView:(UIView *)view {
    if([[UIApplication sharedApplication] isIgnoringInteractionEvents]){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
