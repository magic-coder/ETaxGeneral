/************************************************************
 Class    : BaseSecurityUtil.h
 Describe : 安全加密解密工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface BaseSecurityUtil : NSObject

SingletonH(BaseSecurityUtil)

// AES加密
- (NSString *)encryptStr:(NSString *)str;

// AES解密
- (NSString *)decryptStr:(NSString *)str;

@end
