/************************************************************
 Class    : YZNetworkingManager.h
 Describe : 自己封装的AFN，包含单向自签名https请求
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface YZNetworkingManager : NSObject

+ (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSString *error))failure
     invalid:(void (^)(NSString *msg))invalid;

+ (void)GET:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSString *error))failure
    invalid:(void (^)(NSString *msg))invalid;

@end
