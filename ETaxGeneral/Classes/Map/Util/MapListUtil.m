/************************************************************
 Class    : MapListUtil.m
 Describe : 地图机构工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MapListUtil.h"
#import "MapListModel.h"

@implementation MapListUtil

SingletonM(MapListUtil)

#pragma mark - 从本地加载数据
- (NSMutableArray *)loadMapData {
    NSDictionary *dict = [[BaseSandBoxUtil sharedBaseSandBoxUtil] loadDataWithFileName:MAP_FILE];
    return [self handleData:dict];
}

#pragma mark - 从服务端初始化数据
- (void)initMapDataSuccess:(void (^)(NSMutableArray *))success
                   failure:(void (^)(NSString *))failure
                   invalid:(void (^)(NSString *))invalid {

    [YZNetworkingManager POST:@"public/taxmap/init" parameters:nil success:^(id responseObject) {
        [[BaseSandBoxUtil sharedBaseSandBoxUtil] writeData:responseObject fileName:MAP_FILE];
        success([self handleData:responseObject]);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
}

#pragma mark - 对返回的数据进行处理
- (NSMutableArray *)handleData:(NSDictionary *)data{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSDictionary *businessData = [data objectForKey:@"businessData"];
    NSArray *dataArray = [businessData objectForKey:@"taxmaplist"];
    for(NSDictionary *dict in dataArray){
        MapListModel *model = [ MapListModel createWithDictionary:dict];
        [array addObject:model];
    }
    
    return array;
}

@end
