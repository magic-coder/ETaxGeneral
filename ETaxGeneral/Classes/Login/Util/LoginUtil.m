/************************************************************
 Class    : LoginUtil.m
 Describe : 用户登录工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-13
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "LoginUtil.h"
#import "OneWayHTTPS.h"

@implementation LoginUtil

SingletonM(LoginUtil)

#pragma mark - 通过app进行登录
- (void)loginWithAppDict:(NSMutableDictionary *)dict
                 success:(void (^)(void))success
                 failure:(void (^)(NSString *))failure {

    // 获取设备信息
    NSDictionary *deviceDict = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_INFO];
    // 设置登录请求基本信息参数
    [dict setValue:@"" forKey:@"userCode"];
    [dict setValue:@"app" forKey:@"loginType"];
    [dict setValue:@"4" forKey:@"phonetype"];
    [dict setValue:[deviceDict objectForKey:@"deviceIdentifier"] forKey:@"deviceid"];
    [dict setValue:[deviceDict objectForKey:@"deviceModel"] forKey:@"phonemodel"];
    [dict setValue:[deviceDict objectForKey:@"systemVersion"] forKey:@"osversion"];
    
    NSString *url = [NSString stringWithFormat:@"%@account/login", SERVER_URL];// 格式化请求 URL 参数
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[BaseHandleUtil sharedBaseHandleUtil] JSONStringWithObject:dict], @"msg", nil];   // 格式化参数
    
    // 登录方法使用封装好的单向 HTTPS 认证请求，不使用 YZNetworkingManager 因为要进行重复登录校验，否则会冲突
    [OneWayHTTPS POST:url parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
            // 移除安全性信息
            [dict removeObjectForKey:@"password"];
            [dict removeObjectForKey:@"imageVerifyCode"];
            // 获取登录成功信息
            NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
            [dict setValue:[businessData objectForKey:@"userMobile"] forKey:@"userMobile"];
            [dict setValue:[businessData objectForKey:@"userCode"] forKey:@"userCode"];
            [dict setValue:[businessData objectForKey:@"userName"] forKey:@"userName"];
            [dict setValue:[businessData objectForKey:@"userPhone"] forKey:@"userPhone"];
            [dict setValue:[businessData objectForKey:@"token"] forKey:@"token"];
            // 获取系统当前时间(登录时间)
            NSDate *sendDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *loginDate = [dateFormatter stringFromDate:sendDate];
            [dict setValue:loginDate forKey:@"loginDate"];
            
            // 将登录成功信息保存到用户单例模式中
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"userMobile"] forKey:LAST_LOGINCODE];    // 记录最近一次登录用户名以便注销后展示
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LOGIN_SUCCESS];
            [[NSUserDefaults standardUserDefaults] synchronize]; // 强制写入（同步）
            
            [self registerPush];// 推送设备绑定
            
            success();
        }else{
            failure([responseObject objectForKey:@"msg"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];

}

#pragma mark - 通过token进行登录
- (void)loginWithTokenSuccess:(void (^)(void))success
                      failure:(void (^)(NSString *))failure
                      invalid:(void (^)(NSString *))invalid {
    DLog(@"开始进行Token登录...");
    
    NSDictionary *deviceDict = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_INFO];
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"appToken" forKey:@"loginType"];
    [dict setObject:@"4" forKey:@"phonetype"];
    [dict setObject:[userDict objectForKey:@"userCode"] forKey:@"userCode"];
    [dict setObject:[userDict objectForKey:@"token"] forKey:@"token"];
    [dict setObject:[deviceDict objectForKey:@"deviceIdentifier"] forKey:@"deviceid"];
    [dict setObject:[deviceDict objectForKey:@"deviceModel"] forKey:@"phonemodel"];
    [dict setObject:[deviceDict objectForKey:@"systemVersion"] forKey:@"osversion"];
    
    NSString *url = [NSString stringWithFormat:@"%@account/login", SERVER_URL];// 格式化请求 URL 参数
    
    // 登录方法使用封装好的单向 HTTPS 认证请求，不使用 YZNetworkingManager 因为要进行重复登录校验，否则会冲突
    [OneWayHTTPS POST:url parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
            NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
            [dict setValue:[businessData objectForKey:@"userMobile"] forKey:@"userMobile"];
            [dict setValue:[businessData objectForKey:@"userCode"] forKey:@"userCode"];
            [dict setValue:[businessData objectForKey:@"userName"] forKey:@"userName"];

            // 获取系统当前时间(登录时间)
            NSDate *sendDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *loginDate = [dateFormatter stringFromDate:sendDate];
            [dict setValue:loginDate forKey:@"loginDate"];
            
            // 登录成功将信息保存到用户单例模式中
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LOGIN_SUCCESS];
            [[NSUserDefaults standardUserDefaults] synchronize]; // 强制写入
            
            [self registerPush];// 推送设备绑定
            
            success();
        }else if([@"510" isEqualToString:[responseObject objectForKey:@"statusCode"]]){ // token 失效需重新登录
            invalid([responseObject objectForKey:@"msg"]);
        }else{
            failure([responseObject objectForKey:@"msg"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark - 用户注销（退出登录）方法

- (void)logout:(void (^)(NSString *))success
       failure:(void (^)(NSString *))failure {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"app" forKey:@"loginType"];
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS];
    [dict setValue:[userDict objectForKey:@"userCode"] forKey:@"userCode"];
    
    NSString *url = [NSString stringWithFormat:@"%@account/loginout", SERVER_URL];// 格式化请求 URL 参数
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[BaseHandleUtil sharedBaseHandleUtil] JSONStringWithObject:dict], @"msg", nil];   // 格式化参数
    
    // 登录方法使用封装好的单向 HTTPS 认证请求，不使用 YZNetworkingManager 因为要进行重复登录校验，否则会冲突
    [OneWayHTTPS POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
            [self clearLocalInfo];
            success([responseObject objectForKey:@"msg"]);
        }else{
            failure([responseObject objectForKey:@"msg"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}


#pragma mark - 注销方法
- (void)clearLocalInfo {
    // 删除用户登录信息
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_SUCCESS];
    // 删除应用列表数据
    [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:APP_FILE];
    [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:APP_SUB_FILE];
    [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:APP_SEARCH_FILE];
    // 删除消息信息
    [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:MSG_FILE];
    // 删除用户设置信息
    // 将用户TouchID设置信息删除
    NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    [settingDict setValue:[NSNumber numberWithBool:NO] forKey:@"gesturePwd"];
    [settingDict setValue:[NSNumber numberWithBool:NO] forKey:@"touchID"];
    [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GESTURES_PASSWORD];
    // 清理缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    // 清空Cookie
    NSHTTPCookieStorage * loginCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie * cookie in [loginCookie cookies]){
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    // 删除沙盒自动生成的Cookies.binarycookies文件
    NSString * path = NSHomeDirectory();
    NSString * filePath = [path stringByAppendingPathComponent:@"/Library/Cookies/Cookies.binarycookies"];
    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:filePath error:nil];
    
}

#pragma mark - 注册推送
- (void)registerPush {
    // 注册推送
    NSString *errorCode = @"0";
    NSString *appId = @"";
    NSString *userId = @"";
    NSString *channelId = @"";
    NSString *phoneProduct = @"Apple";
    NSNumber *deviceType = [NSNumber numberWithInt:4];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN];
    
    NSDictionary *pushDict = [NSDictionary dictionaryWithObjectsAndKeys:errorCode, @"errorCode", appId, @"appId", userId, @"userId", channelId, @"channelId", phoneProduct, @"phoneProduct", deviceType, @"deviceType", deviceToken, @"deviceToken", nil];
    
//    [YZNetworkingManager POST:@"push/registerPush" parameters:pushDict success:^(id responseObject) {
//        DLog(@"推送设备绑定成功！");
//    } failure:^(NSString *error) {
//        DLog(@"推送设备绑定失败：error = %@", error);
//    } invalid:^(NSString *msg) {
//        DLog(@"推送设备绑定失败：msg = %@", msg);
//    }];
}

@end
