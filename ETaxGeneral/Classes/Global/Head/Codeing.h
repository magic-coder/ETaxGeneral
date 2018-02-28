/************************************************************
 Class    : Codeing.h
 Describe : 常用代码片段宏定义，便于程序使用
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-28
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#ifndef Codeing_h
#define Codeing_h

#ifdef  DEBUG
// 在控制台输出Log日志
#define DLog(FORMAT, ...) NSLog((@"Yan输出[Debug Log]%s [Line %d] " FORMAT), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define APPDELEGETE             [[UIApplication sharedApplication] delegate]
#define WINDOW                  [[UIApplication sharedApplication] keyWindow]
#define BUNDLE_IDENTIFIER       [[NSBundle mainBundle] bundleIdentifier]
#define PLACEHOLDER_IMAGE       [UIImage imageNamed:@"common_placeholder"]
#define IS_LOGIN                (nil != [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS])
#define SHOW_LOGIN_VIEW         [self presentViewController:[[NSClassFromString(@"LoginViewController") class] new] animated:YES completion:nil];
#define SHOW_RELOGIN_VIEW \
\
FCAlertView *alert = [[FCAlertView alloc] init]; \
[alert showAlertWithTitle:@"登录失效" \
             withSubtitle:msg \
          withCustomImage:[UIImage imageNamed:@"alert_login"] \
      withDoneButtonTitle:@"重新登录" \
               andButtons:nil]; \
alert.colorScheme = alert.flatRed; \
[alert doneActionBlock:^{ \
    [[LoginUtil sharedLoginUtil] logout]; \
    SHOW_LOGIN_VIEW \
}]; \

#pragma mark - 防止重复点击（间隔1秒）
#define CLICK_LOCK \
\
sender.enabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
sender.enabled = YES; \
}); \

#endif /* Codeing_h */
