/************************************************************
 Class    : NewsUtil.m
 Describe : 首页新闻工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface NewsUtil : NSObject

SingletonH(NewsUtil)

- (void)initDataWithPageSize:(int)pageSize
                     success:(void (^)(NSDictionary *dataDict))success
                     failure:(void(^)(NSString *error))failure
                     invalid:(void (^)(NSString *msg))invalid;

- (void)moreDataWithPageNo:(int)pageNo
                  pageSize:(int)pageSize
                   success:(void (^)(NSArray *dataArray))success
                   failure:(void(^)(NSString *error))failure
                   invalid:(void (^)(NSString *msg))invalid;

@end
