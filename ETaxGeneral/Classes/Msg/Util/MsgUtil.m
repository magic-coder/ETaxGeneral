/************************************************************
 Class    : MsgUtil.m
 Describe : 消息列表工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MsgUtil.h"

@implementation MsgUtil

SingletonM(MsgUtil)

#pragma mark - 获取未读消息条数
- (void)msgUnReadCountSuccess:(void (^)(int))success{
    [YZNetworkingManager POST:@"message/getUnreadCount" parameters:nil success:^(id responseObject) {
        NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
        int unReadCount = [[businessData objectForKey:@"unReadCount"] intValue];
        success(unReadCount);
    } failure:^(NSString *error) {
        success(0);
    } invalid:^(NSString *msg) {
        success(0);
    }];
    
}

#pragma mark - 从本地消息缓存文件中读取消息列表
- (NSDictionary *)loadMsgFile {
    return [[BaseSandBoxUtil sharedBaseSandBoxUtil] loadDataWithFileName:MSG_FILE];
}

#pragma mark - 加载分组消息列表的数据
- (void)loadMsgListPageNo:(int)pageNo pageSize:(int)pageSize
                  success:(void (^)(NSDictionary *))success
                  failure:(void (^)(NSString *))failure
                  invalid:(void (^)(NSString *))invalid{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:pageNo] forKey:@"pageNo"];
    [dict setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    
    [YZNetworkingManager POST:@"message/getMsgList" parameters:dict success:^(id responseObject) {
        NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
        NSArray *results = [businessData objectForKey:@"results"];
        if(results.count <= 0){
            [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:MSG_FILE];// 删除本地 msg 数据信息
        }
        NSDictionary *resDict = @{@"results" : results};
        [[BaseSandBoxUtil sharedBaseSandBoxUtil] writeData:resDict fileName:MSG_FILE];// 写入本地缓存 SandBox
        
        success(resDict);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
}

#pragma mark - 删除分组消息列表数据
- (void)deleteMsgListSourceCode:(NSString *)sourceCode pushOrgCode:(NSString *)pushOrgCode
                        success:(void (^)(void))success
                        failure:(void (^)(NSString *))failure
                        invalid:(void (^)(NSString *))invalid {
    
    [YZNetworkingManager POST:@"message/delMsgBySource" parameters:@{@"sourcecode" : sourceCode, @"swjgdm" : pushOrgCode} success:^(id responseObject) {
        success();
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
    
}

#pragma mark - 加载消息明细信息
- (void)loadMsgDetailParameters:(NSDictionary *)parameters
                   success:(void (^)(NSDictionary *))success
                   failure:(void (^)(NSString *))failure
                   invalid:(void (^)(NSString *))invalid {
    
    [YZNetworkingManager POST:@"message/getMsgDetail" parameters:parameters success:^(id responseObject) {
        NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
        NSString *totalPage = [businessData objectForKey:@"totalPage"];
        NSArray *results = [businessData objectForKey:@"results"];
        
        NSDictionary *resDict = [NSDictionary dictionaryWithObjectsAndKeys:totalPage, @"totalPage", results, @"results", nil];
        success(resDict);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
    
}
#pragma mark - 删除消息明细信息
- (void)deleteMsgDetailUuid:(NSString *)uuid
                    success:(void (^)(void))success
                    failure:(void (^)(NSString *))failure
                    invalid:(void (^)(NSString *))invalid {
    
    [YZNetworkingManager POST:@"message/delMsgByItem" parameters:@[@{@"pushdetailuuid" : uuid}] success:^(id responseObject) {
        success();
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
    
}

@end
