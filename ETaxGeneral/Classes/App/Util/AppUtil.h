/************************************************************
 Class    : AppUtil.h
 Describe : 应用模块工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject

SingletonH(AppUtil)

- (NSMutableDictionary *)loadAppData;

- (void)initAppDataSuccess:(void (^)(NSMutableDictionary *dataDict))success
                   failure:(void(^)(NSString *error))failure
                   invalid:(void (^)(NSString *msg))invalid;

- (BOOL)writeAppData:(NSDictionary *)appData;// 写入菜单列表（初始化数据、编辑时调用）

- (NSMutableArray *)loadSubDataWithPno:(NSString *)pno level:(NSString *)level;

- (NSMutableArray *)loadSearchData;

/// 向服务器保存自定义app排序
- (void)saveCustomData:(NSArray *)customData
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSString *error))failure
               invalid:(void (^)(NSString *msg))invalid;


@end
