/************************************************************
 Class    : NewsUtil.m
 Describe : 首页新闻工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "NewsUtil.h"

@implementation NewsUtil

SingletonM(NewsUtil)

- (void)initDataWithPageSize:(int)pageSize
                     success:(void (^)(NSDictionary *))success
                     failure:(void (^)(NSString *))failure
                     invalid:(void (^)(NSString *))invalid {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    
    [YZNetworkingManager POST:@"public/photonews/index" parameters:dict success:^(id responseObject) {
        NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
        NSArray *loopData = [businessData objectForKey:@"loopData"];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSMutableArray *releasedates = [[NSMutableArray alloc] init];
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        for(NSDictionary *loopDict in loopData){
            [images addObject:[loopDict objectForKey:@"IMAGE"]];
            [releasedates addObject:[loopDict objectForKey:@"RELEASEDATE"]];
            [titles addObject:[loopDict objectForKey:@"TITLE"]];
            [urls addObject:[loopDict objectForKey:@"URL"]];
        }
        NSDictionary *loopResult = [NSDictionary dictionaryWithObjectsAndKeys:images, @"images", releasedates, @"releasedates", titles, @"titles", urls, @"urls", nil];
        NSDictionary *newsData = [businessData objectForKey:@"newsData"];
        NSArray *newsResult = [newsData objectForKey:@"results"];
        NSString *totalPage = [newsData objectForKey:@"totalPage"];
        
        NSDictionary *resDict = [NSDictionary dictionaryWithObjectsAndKeys:loopResult, @"loopResult", newsResult, @"newsResult", totalPage, @"totalPage", nil];
        
        success(resDict);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
}

- (void)moreDataWithPageNo:(int)pageNo
                  pageSize:(int)pageSize
                   success:(void (^)(NSArray *))success
                   failure:(void (^)(NSString *))failure
                   invalid:(void (^)(NSString *))invalid {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:pageNo] forKey:@"pageNo"];
    [dict setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    
    [YZNetworkingManager POST:@"public/photonews/queryPhotoNewsList" parameters:dict success:^(id responseObject) {
        
        NSDictionary *businessData = [responseObject objectForKey:@"businessData"];
        NSArray *dataArray = [businessData objectForKey:@"results"];
        
        success(dataArray);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
    
}

@end
