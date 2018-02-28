/************************************************************
 Class    : Variable.m
 Describe : 全局参数
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "Variable.h"

@implementation Variable

SingletonM(Variable)

- (NSString *)appName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用显示名称
    return [infoDictionary objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)appVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用版本号码 int类型
    // NSInteger appVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    // 当前应用软件版本 如：1.0.1
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件build号 如：163297
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

@end
