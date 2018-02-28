/************************************************************
 Class    : BaseSandBoxUtil.h
 Describe : 基本的沙盒SandBox操作(读、写、删)
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface BaseSandBoxUtil : NSObject

// 单例模式方法
SingletonH(BaseSandBoxUtil)

- (NSMutableDictionary *)loadDataWithFileName:(NSString *)fileName;     // 读取文件

- (BOOL)writeData:(NSDictionary *)data fileName:(NSString *)fileName;   // 写入文件

- (void)removeFileName:(NSString *)fileName;                            // 删除文件

@end
