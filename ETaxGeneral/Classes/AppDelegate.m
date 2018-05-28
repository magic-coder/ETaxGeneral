/************************************************************
 Class    : AppDelegate.m
 Describe : 应用主委托代理类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-09
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "MainNavigationController.h"
#import "GestureViewController.h"
#import "MsgListViewController.h"
#import "MsgUtil.h"
#import "AFNetworkReachabilityManager.h"        // 监测网络状态

#import <BaiduMapAPI_Base/BMKBaseComponent.h>   // BaiduMap引入base相关所有的头文件
#import <UserNotifications/UserNotifications.h> // 推送服务

#import <AudioToolbox/AudioToolbox.h>

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "AuthHelper.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate, SangforSDKDelegate>

@property (nonatomic, strong) MainTabBarController *rootVC; // 根视图

@property (nonatomic, strong) BMKMapManager *mapManager;    // 百度 Map 初始化

@property (nonatomic, strong) UIVisualEffectView *blurView; // 多任务后台毛玻璃遮挡效果视图

@property (nonatomic, strong) AuthHelper *helper;           // VPN 处理类

// 启动动画遮挡
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) UIView *maskBackgroundView;

// 记录使用时间
@property (nonatomic, assign) double beginTimestamp;
@property (nonatomic, assign) double endTimestamp;

@property (nonatomic, assign) int networkChange;            // 网络环境切换次数（控制首次不进行网络提示）

@end

@implementation AppDelegate

#pragma mark - 程序加载完毕
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 设置主window视图
    _window = [[UIWindow alloc] initWithFrame:FRAME_SCREEN];
    _window.backgroundColor = DEFAULT_BLUE_COLOR;
    
    // 设置root视图控制器
    _rootVC = [MainTabBarController sharedMainTabBarController];
    _window.rootViewController = _rootVC;
    [_window makeKeyAndVisible];
    
    [self welcomeAnimationMask];    // 加载启动动画遮挡（VPN认证完毕后会移除动画遮挡）
    
    // 判断系统版本是否支持
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert showAlertWithTitle:@"当前系统版本过低"
                 withSubtitle:@"请在iPhone的\"设置-通用-软件更新\"中升级您的操作系统至ios10.0以上再使用。"
              withCustomImage:nil
          withDoneButtonTitle:@"退出应用"
                   andButtons:nil];
    [alert makeAlertTypeWarning];
    [alert doneActionBlock:^{
        exit(0);
    }];
#else
    [self detectNetwork];       // 检测当前网络状态（若正常，则在该方法中进行VPN认证）
    
    [[BaseHandleUtil sharedBaseHandleUtil] currentDeviceInfo]; // 获取设备基本信息
    [[BaseSettingUtil sharedBaseSettingUtil] initSettingData]; // 初始化基本设置信息
    
    [self registerNotification];    // 注册推送服务
    [self initializeBaiduMap];      // 百度地图 BMKMapManager 初始化
    [self verifyUnlock];            // 判断是否设置安全密码
    [self monitoringScreenShot];    // 监测截屏操作
    //[self cameraAndPhotoStatus];    // 设置权限
    
#endif
    
    return YES;
}

#pragma mark - 程序失去焦点
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    _endTimestamp = floor([[NSDate date] timeIntervalSince1970]);   // 获取使用结束时间戳
    
    // 本次使用时长
    int duration = _endTimestamp - _beginTimestamp;
    if(IS_LOGIN && duration > 10){
        // 开始调用统计在线时长接口，记录使用时间
        DLog(@"本次使用时长为：duration = %d", duration);
        [YZNetworkingManager POST:@"level/obtion" parameters:@{@"scoreType" : @"0", @"duration" : [NSString stringWithFormat:@"%d", duration]} success:^(id responseObject) {
        } failure:^(NSString *error) {
        } invalid:^(NSString *msg) {
        }];
    }
}

#pragma mark - 程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self showBlurView:YES];// 开启遮挡视图
}

#pragma mark - 程序从后台回到前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    [self verifyUnlock];// 判断是否设置安全密码
}

#pragma mark - 程序获取焦点
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    _beginTimestamp = floor([[NSDate date] timeIntervalSince1970]); // 获取开始使用时间戳
    [self showBlurView:NO];// 开启遮挡视图
}

#pragma mark - 程序即将退出
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

#pragma mark - 程序内存警告，可能要终止程序
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    DLog(@"程序内存警告，可能要终止程序");
}

#pragma mark - 百度地图 BMKMapManager 初始化
- (void)initializeBaiduMap {
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定 generalDelegate 参数
    BOOL ret = [_mapManager start:BaiduMap_Key generalDelegate:nil];
    if (!ret) {
        DLog(@"百度地图管理器启动失败!");
    }
}

#pragma mark - 检测网络状态
- (void)detectNetwork {
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        _networkChange++;
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
            {
                if(_networkChange > 1)
                    [JDStatusBarNotification showWithStatus:@"未知网络" dismissAfter:1.6f styleName:JDStatusBarStyleDark];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
            {
                DLog(@"没有网络");
                if(_networkChange > 1){
                    [JDStatusBarNotification showWithStatus:@"没有网络，请检查网络设置是否正常！" styleName:JDStatusBarStyleError];
                }else{
                    _networkChange = 0;
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert showAlertWithTitle:@"没有网络"
                                 withSubtitle:@"无法连接网络，请检查网络设置是否正常！"
                              withCustomImage:[UIImage imageNamed:@"alert_network"]
                          withDoneButtonTitle:@"我知道了"
                                   andButtons:nil];
                    alert.colorScheme = alert.flatGray;
                }
                    
                return;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: // 蜂窝移动数据
            {
                DLog(@"蜂窝移动网络");
                if(_networkChange > 1)
                    [JDStatusBarNotification showWithStatus:@"蜂窝移动网络" dismissAfter:1.6f styleName:JDStatusBarStyleDark];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
            {
                DLog(@"WIFI网络");
                if(_networkChange > 1)
                    [JDStatusBarNotification showWithStatus:@"WIFI网络" dismissAfter:1.6f styleName:JDStatusBarStyleDark];
                break;
            }
        }
        [self initializeVPN];       // 网络正常，开始初始化、认证VPN
    }];
    // 3.开始监控
    [manager startMonitoring];
}

#pragma mark - 注册推送通知服务
- (void)registerNotification {
    // 注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self; // 必须写代理，否则无法监听通知的接收与点击
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 点击允许
            DLog(@"推送服务注册成功");
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                DLog(@"settings = %@", settings);
            }];
        } else {
            // 点击不允许
            DLog(@"推送服务注册失败");
        }
    }];
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
#pragma mark 注册推送获得Device Token成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                 stringByReplacingOccurrencesOfString:@">" withString:@""]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"推送通知注册成功! Device Token: %@", deviceTokenStr);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 注册推送获得Device Token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"推送通知注册失败! Error: %@", error);
}
#pragma mark 接受到推送通知代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    if([userInfo[@"sourceCode"] isEqualToString:@"99"] && IS_LOGIN){    // 下线通知
        [[LoginUtil sharedLoginUtil] clearLocalInfo];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"安全提醒"
                     withSubtitle:@"该账号已在其他设备登录，请重新登录。"
                  withCustomImage:nil
              withDoneButtonTitle:@"我知道了"
                       andButtons:nil];
        [alert makeAlertTypeCaution];
        
        UIViewController *vc = [[BaseHandleUtil sharedBaseHandleUtil] topViewController];
        NSInteger vcCount = vc.navigationController.viewControllers.count;
        DLog(@"%ld", vcCount);
        if(vcCount > 1){
            [vc.navigationController popToRootViewControllerAnimated:NO];// pop掉全部的视图控制器
        }else{
            [vc presentViewController:[[MainNavigationController alloc] initWithRootViewController:[[NSClassFromString(@"LoginViewController") class] new]] animated:YES completion:nil];// 跳转到登录界面
        }
    }
    
    if([userInfo[@"sourceCode"] isEqualToString:@"01"]){    // 用户推送
        
        // 读取系统设置文件内容(声音/震动)
        NSDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
        BOOL voiceOn = [[settingDict objectForKey:@"voice"] boolValue];
        BOOL shakeOn = [[settingDict objectForKey:@"shake"] boolValue];
        
        if(voiceOn){ // 调用声音代码
            //AudioServicesPlaySystemSound(1007); //其中1007是系统声音的编号，其他的可用编号：
            [[BaseHandleUtil sharedBaseHandleUtil] playSoundEffect:@"msgsound" type:@"caf"];
        }
        if(shakeOn){ // 调用震动代码
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if(_rootVC.selectedIndex == 2){
            MsgListViewController *msgListVC = (MsgListViewController *)[[BaseHandleUtil sharedBaseHandleUtil] topViewController];
            [msgListVC loadData];
        }else{
            int badge = [Variable sharedVariable].unReadCount+1;
            // 设置tabBar消息角标
            [_rootVC.tabBar.items objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%d", badge];
        }
        
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
        
    }
}
#pragma mark 推送通知交互方法，如：用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    if([userInfo[@"sourceCode"] isEqualToString:@"99"] && IS_LOGIN){    // 下线通知
        _rootVC.selectedIndex = 3;
        [[LoginUtil sharedLoginUtil] clearLocalInfo];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"安全提醒"
                     withSubtitle:@"该账号已在其他设备登录，请重新登录。"
                  withCustomImage:nil
              withDoneButtonTitle:@"我知道了"
                       andButtons:nil];
        [alert makeAlertTypeCaution];
        
        UIViewController *vc = [[BaseHandleUtil sharedBaseHandleUtil] topViewController];
        [vc presentViewController:[[MainNavigationController alloc] initWithRootViewController:[[NSClassFromString(@"LoginViewController") class] new]] animated:YES completion:nil];// 跳转到登录界面
    }
    
    if([userInfo[@"sourceCode"] isEqualToString:@"01"]){    // 用户推送
        _rootVC.selectedIndex = 2;
        if([Variable sharedVariable].vpnSuccess){
            MsgListViewController *msgListVC = (MsgListViewController *)[[BaseHandleUtil sharedBaseHandleUtil] topViewController];
            [msgListVC loadData];
        }
    }
    completionHandler();  // 系统要求执行这个方法
}

#pragma mark - 判断是否开启了手势密码、指纹解锁功能
- (void)verifyUnlock {
    
    MainTabBarController *mainTabBarController = [MainTabBarController sharedMainTabBarController];
    
    if(IS_LOGIN){
        // 校验用户是否开启了手势密码、指纹解锁，并进行相应跳转
        NSDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
        
        if([[settingDict objectForKey:@"touchID"] boolValue]){  // 指纹解锁
            [mainTabBarController presentViewController:[[NSClassFromString(@"TouchIDViewController") class] new] animated:NO completion:nil];
        }else{
            if([[settingDict objectForKey:@"gesturePwd"] boolValue]){
                NSString *gesturePwd = [[NSUserDefaults standardUserDefaults] objectForKey:GESTURES_PASSWORD];
                if(gesturePwd.length > 0){  // 手势验证解锁
                    GestureViewController *gestureVC = [[GestureViewController alloc] init];
                    [gestureVC setType:GestureViewControllerTypeLogin];
                    
                    [mainTabBarController presentViewController:gestureVC animated:NO completion:nil];
                }
            }
        }
    }
}

#pragma mark - 切换后台缩略图毛玻璃遮挡
- (void) showBlurView:(BOOL)isMask{
    if(isMask){
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.blurView];
    }
    [UIView animateWithDuration:0 animations:^{
        self.blurView.alpha = isMask ? 0.97f : 0;
    } completion:^(BOOL finished) {
        if (!isMask){
            [self.blurView removeFromSuperview];
        }
    }];
}
#pragma mark 毛玻璃遮挡视图效果
- (UIVisualEffectView *)blurView{
     if (!_blurView) {
     UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
     //  毛玻璃view 视图
     _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
     _blurView.frame = [[UIApplication sharedApplication] keyWindow].bounds;
     _blurView.alpha = 0;
     }
     return _blurView;
}
#pragma mark - 监测截屏操作，截屏给予提示
- (void)monitoringScreenShot {
    // 检测截屏操作 ------>开始<------
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note){
        [self screenShotHint];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenShotHint) name:UIApplicationUserDidTakeScreenshotNotification  object:nil];  //这个写法是针对于当前控制器
    
    //离开当前控制器的时候  最好移除通知
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(screenShotHint) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    // 检测截屏操作 ------>结束<------
}
#pragma mark 截屏提示信息
- (void)screenShotHint {
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert showAlertWithTitle:@"安全提醒"
                 withSubtitle:@"内部信息，只适合当面使用。不要截图或分享给他人以保障信息安全。"
              withCustomImage:nil
          withDoneButtonTitle:@"绝不给别人"
                   andButtons:nil];
    [alert makeAlertTypeCaution];
}

#pragma mark - 启动欢迎动画加载方法
#pragma mark 启动欢迎动画遮挡
- (void)welcomeAnimationMask {
    //logo mask
    _maskLayer = [CALayer layer];
    _maskLayer.contents = (id)[UIImage imageNamed:@"common_launch"].CGImage;
    _maskLayer.position = _rootVC.view.center;
    _maskLayer.bounds = CGRectMake(0, 0, 60, 60);
    _rootVC.view.layer.mask = _maskLayer;
    
    //logo mask background view
    _maskBackgroundView = [[UIView alloc]initWithFrame:_rootVC.view.bounds];
    _maskBackgroundView.backgroundColor = [UIColor whiteColor];
    [_rootVC.view addSubview:_maskBackgroundView];
    [_rootVC.view bringSubviewToFront:_maskBackgroundView];
}
#pragma mark 启动欢迎动画移除
- (void)welcomeAnimationFade {
    
    //logo mask animation
    CAKeyframeAnimation *logoMaskAnimaiton = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    logoMaskAnimaiton.duration = 1.0f;
    logoMaskAnimaiton.beginTime = CACurrentMediaTime() + 1.0f;//延迟1秒
    
    CGRect initalBounds = _maskLayer.bounds;
    CGRect secondBounds = CGRectMake(0, 0, 50, 50);
    CGRect finalBounds  = CGRectMake(0, 0, 5000, 5000);
    logoMaskAnimaiton.values = @[[NSValue valueWithCGRect:initalBounds],[NSValue valueWithCGRect:secondBounds],[NSValue valueWithCGRect:finalBounds]];
    logoMaskAnimaiton.keyTimes = @[@(0),@(0.5),@(1)];
    logoMaskAnimaiton.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    logoMaskAnimaiton.removedOnCompletion = NO;
    logoMaskAnimaiton.fillMode = kCAFillModeForwards;
    [_rootVC.view.layer.mask addAnimation:logoMaskAnimaiton forKey:@"logoMaskAnimaiton"];
    
    //maskBackgroundView fade animation
    [UIView animateWithDuration:0.1f delay:1.35f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _maskBackgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_maskBackgroundView removeFromSuperview];
        
        if(IS_LOGIN){
            // 隐藏顶部状态栏设为NO
            [UIApplication sharedApplication].statusBarHidden = NO;
            // 节日动画下落效果（下雪、红包、福袋...）
            // [[BaseHandleUtil sharedBaseHandleUtil] snowAnimation];
            // 获取未读消息条数
            [[MsgUtil sharedMsgUtil] msgUnReadCountSuccess:^(int unReadCount) {
                [Variable sharedVariable].unReadCount = unReadCount;
                [[BaseHandleUtil sharedBaseHandleUtil] msgBadge:unReadCount];   // 设置未读消息角标提示
            }];
        }
        // 设置顶部状态栏字体为白色
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    }];
}

#pragma mark - 初始化VPN方法
- (void)initializeVPN {
    // 判断VPN是否已经初始化登录
    if (VPN_STATUS_OK == [self.helper vpnQueryStatus]){
        DLog(@"VPN 当前是已经登录状态，注销后才能再登录");
        return;
    }
    self.helper = [AuthHelper getInstance];
    [self.helper init:EasyApp host:[[BaseSecurityUtil sharedBaseSecurityUtil] decryptStr:VPN_HOST] port:[[[BaseSecurityUtil sharedBaseSecurityUtil] decryptStr:VPN_PORT] intValue] delegate:self];
}
#pragma mark - 初始化用户名、密码认证参数
- (void)initializeAuthParam {
    [self.helper setAuthParam:@PORPERTY_NamePasswordAuth_NAME param:[[BaseSecurityUtil sharedBaseSecurityUtil] decryptStr:VPN_USERNAME]];
    [self.helper setAuthParam:@PORPERTY_NamePasswordAuth_PASSWORD param:[[BaseSecurityUtil sharedBaseSecurityUtil] decryptStr:VPN_PASSWORD]];
}
#pragma mark - <SangforSDKDelegate> VPN 代理方法
- (void)onCallBack:(const VPN_RESULT_NO)vpnErrno authType:(const int)authType {
    
    NSString *vpnMsg = nil;
    
    switch (vpnErrno) {
        case RESULT_VPN_INIT_FAIL: {
            vpnMsg = @"VPN 初始化失败！";
            break;
        }
        case RESULT_VPN_AUTH_FAIL: {
            [self.helper clearAuthParam:@SET_RND_CODE_STR];
            [self.helper vpnQueryStatus];
            vpnMsg = @"VPN 认证失败！";
            break;
        }
        case RESULT_VPN_INIT_SUCCESS: {
            //显示当前sdk版本号
            NSString *version = [self.helper getSdkVersion];
            DLog(@"VPN 初始化成功！版本号：%@", version);
            
            [self.helper setAuthParam:@AUTH_DEVICE_LANGUAGE param:@"en_US"];//zh_CN or en_US
            
            [self initializeAuthParam];// 初始化VPN用户名、密码参数
            
            [self.helper loginVpn:SSL_AUTH_TYPE_PASSWORD];
            break;
        }
        case RESULT_VPN_AUTH_SUCCESS: {
            DLog(@"VPN 认证成功！");
            [self startAuth:authType];
            break;
        }
        case RESULT_VPN_AUTH_LOGOUT: {
            DLog(@"VPN 注销！");
            break;
        }
        case RESULT_VPN_OTHER: {
            vpnMsg = @"VPN 返回其他状态！";
            break;
        }
        case RESULT_VPN_NONE: {
            vpnMsg = @"VPN 值无效！";
            break;
        }
        case RESULT_VPN_L3VPN_FAIL: {
            [self.helper clearAuthParam:@SET_RND_CODE_STR];
            vpnMsg = @"L3VPN 启动失败！";
            break;
        }
        default: {
            vpnMsg = @"VPN 未知错误！";
            break;
        }
    }
    
    if(vpnMsg){
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"VPN连接失败"
                     withSubtitle:[NSString stringWithFormat:@"由于：\"%@\"，导致您无法正常使用，请稍后再试或联系管理员。", vpnMsg]
                  withCustomImage:[UIImage imageNamed:@"alert_vpn"]
              withDoneButtonTitle:@"退出应用"
                       andButtons:nil];
        alert.colorScheme = alert.flatRed;
        [alert doneActionBlock:^{
            exit(0);
        }];
    }
    
}
#pragma mark - VPN开始认证方法
- (void) startAuth:(const int)authType {
    switch (authType) {
        case SSL_AUTH_TYPE_CERTIFICATE: {
            DLog(@"Start Certificate Auth！");
            break;
        }
        case SSL_AUTH_TYPE_PASSWORD: {
            DLog(@"Start Password Name Auth！");
            [self initializeAuthParam]; // 初始化VPN用户名、密码参数
            break;
        }
        case SSL_AUTH_TYPE_NONE: {
            DLog(@"VPN Auth Success!");
            [Variable sharedVariable].vpnSuccess = YES; // 设置VPN认证标志为成功
            [self welcomeAnimationFade];    // 移除欢迎动画
            return;
        }
        case SSL_AUTH_TYPE_SMS: {
            DLog(@"Start SMS Auth！");
            break;
        }
        case SSL_AUTH_TYPE_RADIUS: {
            DLog(@"Start Radius Auth！");
            break;
        }
        case SSL_AUTH_TYPE_TOKEN: {
            DLog(@"Start Token Auth！");
            break;
        }
        default: {
            DLog(@"Unknowm Failed！");
            return;
        }
    }
    [self.helper loginVpn:authType];
}

#pragma mark - 开始获取相册、相机权限
/*
- (void)cameraAndPhotoStatus{
    //相机权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限
        authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问
    {
        // 无权限 引导去开启
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    
    // 相册权限
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author ==PHAuthorizationStatusRestricted || author ==PHAuthorizationStatusDenied){
        //无权限 引导去开启
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    
}
*/
 
@end
