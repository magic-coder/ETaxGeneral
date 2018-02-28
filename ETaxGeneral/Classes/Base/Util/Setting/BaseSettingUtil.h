/************************************************************
 Class    : BaseSettingUtil.h
 Describe : 系统设置处理工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface BaseSettingUtil : NSObject

SingletonH(BaseSettingUtil)

- (void)initSettingData;// 初始化setting设置信息

- (NSMutableDictionary *)loadSettingData;// 读取已有的设置数据

- (BOOL)writeSettingData:(NSMutableDictionary *)data;// 写入设置数据

- (void)removeSettingData;// 清空设置

@end
