/************************************************************
 Class    : Variable.h
 Describe : 全局参数
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface Variable : NSObject

SingletonH(Variable)

@property (nonatomic, strong) NSString *appName;            // 应用名称
@property (nonatomic, strong) NSString *appVersion;         // 应用版本号
@property (nonatomic, strong) NSString *buildVersion;       // 编译版本号

@property (nonatomic, assign) int unReadCount;              // 未读消息条数
@property (nonatomic, assign) BOOL vpnSuccess;              // VPN是否认证成功

@end
