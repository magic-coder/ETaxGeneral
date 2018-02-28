/************************************************************
 Class    : MsgUtil.h
 Describe : 消息列表工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MsgUtil : NSObject

SingletonH(MsgUtil)

// 获取未读消息条数
- (void)msgUnReadCountSuccess:(void(^)(int unReadCount))success;

// 从本地消息缓存文件中读取消息列表
- (NSDictionary *)loadMsgFile;

// 加载分组消息列表的数据
- (void)loadMsgListPageNo:(int)pageNo pageSize:(int)pageSize
                  success:(void(^)(NSDictionary *dataDict))success
                  failure:(void(^)(NSString *error))failure
                  invalid:(void (^)(NSString *msg))invalid;

// 删除分组消息列表数据
- (void)deleteMsgListSourceCode:(NSString *)sourceCode
                    pushOrgCode:(NSString *)pushOrgCode
                        success:(void(^)(void))success
                        failure:(void(^)(NSString *error))failure
                        invalid:(void (^)(NSString *msg))invalid;

// 加载消息明细信息
- (void)loadMsgDetailParameters:(NSDictionary *)parameters
                 success:(void (^)(NSDictionary *dataDict))success
                    failure:(void (^)(NSString *error))failure
                   invalid:(void (^)(NSString *msg))invalid;

// 删除消息明细信息
- (void)deleteMsgDetailUuid:(NSString *)uuid
                    success:(void (^)(void))success
                     failure:(void (^)(NSString *error))failure
                    invalid:(void (^)(NSString *msg))invalid;

@end
