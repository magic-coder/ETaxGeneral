/************************************************************
 Class    : YZNetworkingManager.m
 Describe : 自己封装的AFN，包含单向自签名https请求
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "YZNetworkingManager.h"
#import "OneWayHTTPS.h"

@implementation YZNetworkingManager

+ (void)POST:(NSString *)URLString parameters:(id)parameters
     success:(void (^)(id))success
     failure:(void (^)(NSString *))failure
     invalid:(void (^)(NSString *))invalid {
    
    // 格式化请求 URL 参数
    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_URL, URLString];
    NSDictionary *param = nil;
    if(parameters){
        param = [NSDictionary dictionaryWithObjectsAndKeys:[[BaseHandleUtil sharedBaseHandleUtil] JSONStringWithObject:parameters], @"msg", nil];   // 格式化参数
    }
    
    [OneWayHTTPS POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
            success(responseObject);
        }else{
            [[LoginUtil sharedLoginUtil] loginWithTokenSuccess:^{
                // token 登录成功，重新开始业务请求
                [OneWayHTTPS POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
                        success(responseObject);
                    }else if([@"500" isEqualToString:[responseObject objectForKey:@"statusCode"]]){ // 用户未登录
                        invalid(@"未登录，登录后即可使用该功能");
                    }else if([@"510" isEqualToString:[responseObject objectForKey:@"statusCode"]]){ // token 登录失效
                        invalid(@"登录已失效，请重新登录");
                    }else{
                        failure([responseObject objectForKey:@"msg"]);
                    }
                } failure:^(NSURLSessionDataTask *task, NSString *error) {
                    failure(error);
                }];
            } failure:^(NSString *error) {
                failure(error);
            } invalid:^(NSString *msg) {
                invalid(msg);
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

+ (void)GET:(NSString *)URLString parameters:(id)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSString *))failure
    invalid:(void (^)(NSString *))invalid {
    
    // 格式化请求 URL 参数
    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_URL, URLString];
    NSDictionary *param = nil;
    if(parameters){
        param = [NSDictionary dictionaryWithObjectsAndKeys:[[BaseHandleUtil sharedBaseHandleUtil] JSONStringWithObject:parameters], @"msg", nil];   // 格式化参数
    }
    
    [OneWayHTTPS GET:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
            success(responseObject);
        }else{
            [[LoginUtil sharedLoginUtil] loginWithTokenSuccess:^{
                // token 登录成功，重新开始业务请求
                [OneWayHTTPS POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
                    if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
                        success(responseObject);
                    }else if([@"500" isEqualToString:[responseObject objectForKey:@"statusCode"]]){ // 用户未登录
                        invalid(@"未登录，登录后即可使用该功能");
                    }else if([@"510" isEqualToString:[responseObject objectForKey:@"statusCode"]]){ // token 登录失效
                        invalid(@"登录已失效，请重新登录");
                    }else{
                        failure([responseObject objectForKey:@"msg"]);
                    }
                } failure:^(NSURLSessionDataTask *task, NSString *error) {
                    failure(error);
                }];
            } failure:^(NSString *error) {
                failure(error);
            } invalid:^(NSString *msg) {
                invalid(msg);
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
    
}

@end
