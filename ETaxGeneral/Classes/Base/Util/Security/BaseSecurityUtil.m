/************************************************************
 Class    : BaseSecurityUtil.h
 Describe : 安全加密解密工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseSecurityUtil.h"
#import "AES.h"

#define SECRET_KEY  @"https://github.com/micyo202"

@implementation BaseSecurityUtil

SingletonM(BaseSecurityUtil)

#pragma mark - AES加密
- (NSString *)encryptStr:(NSString *)str {
    return [AES encrypt:str password:SECRET_KEY];
}

#pragma mark - AES解密
- (NSString *)decryptStr:(NSString *)str {
    return [AES decrypt:str password:SECRET_KEY];
}

@end
