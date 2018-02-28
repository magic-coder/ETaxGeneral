/************************************************************
 Class    : MineUtil.h
 Describe : 我的模块处理工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-07
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MineUtil : NSObject

SingletonH(MineUtil)

// 我的数据（第一级）
- (NSMutableArray *)mineData;

// 我的用户信息（第二级）
- (NSMutableArray *)accountData;
// 安全中心数据（第二级）
- (NSMutableArray *)safeData;
// 我的日程数据（第二级）
- (NSMutableArray *)scheduleData;
// 我的客服数据（第二级）
- (NSMutableArray *)serviceData;
// 设置数据（第二级）
- (NSMutableArray *)settingData;

@end
