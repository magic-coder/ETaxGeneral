/************************************************************
 Class    : LoginUtil.h
 Describe : 用户登录工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-13
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface LoginUtil : NSObject

SingletonH(LoginUtil)

// 通过app进行登录
- (void)loginWithAppDict:(NSMutableDictionary *)dict
                 success:(void (^)(void))success
                 failure:(void (^)(NSString *error))failure;

// 通过token进行登录
- (void)loginWithTokenSuccess:(void (^)(void))success
                      failure:(void (^)(NSString *error))failure
                      invalid:(void (^)(NSString *msg))invalid;

// 用户注销（退出登录）方法
 - (void)logout:(void (^)(NSString *msg))success
 failure:(void (^)(NSString *error))failure;

- (void)clearLocalInfo;



@end
