/************************************************************
 Class    : AppUtil.m
 Describe : 应用模块工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppUtil.h"
#import "AppModel.h"
#import "AFNetworking.h"

@implementation AppUtil

SingletonM(AppUtil)

- (NSMutableDictionary *)loadAppData{
    return [[BaseSandBoxUtil sharedBaseSandBoxUtil] loadDataWithFileName:APP_FILE];
}

- (void)initAppDataSuccess:(void (^)(NSMutableDictionary *))success
                   failure:(void (^)(NSString *))failure
                   invalid:(void (^)(NSString *))invalid {
    
    [YZNetworkingManager POST:@"app/index" parameters:nil success:^(id responseObject) {
        int serverIconVer = [[[[responseObject objectForKey:@"businessData"] objectForKey:@"iconVersion"] objectForKey:@"iconVersionNo"] intValue];// 服务端图标版本号
        int nativeIconVer = [[[NSUserDefaults standardUserDefaults] objectForKey:ICON_VERSION] intValue];// 本地图标版本号
        if(serverIconVer != nativeIconVer){
            // 重写本地图标版本号、清图片缓存
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", serverIconVer] forKey:ICON_VERSION];
            [[NSUserDefaults standardUserDefaults] synchronize]; // 强制写入
            // 清理缓存
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            [[SDImageCache sharedImageCache] clearMemory];
        }
        
        NSMutableArray *mineData = [[NSMutableArray alloc] init];
        NSMutableArray *otherData = [[NSMutableArray alloc] init];
        NSMutableArray *allData = [[NSMutableArray alloc] init];
        // 搜索的数据(全部数据各level的)
        NSMutableArray *searchData = [[NSMutableArray alloc] init];
        
        // 子类数据
        NSMutableArray *subData = [[NSMutableArray alloc] init];
        
        NSMutableArray *appData = [[responseObject objectForKey:@"businessData"] objectForKey:@"appList"];
        for(NSDictionary *dict in appData){
            int type = [[dict objectForKey:@"apptype"] intValue];  // 1:我的应用 2:其他应用 3:新增应用
            NSInteger level = [[dict objectForKey:@"applevel"] integerValue];
            if(level == 0){ // 只获取第一个级别的 level = 0 的数据
                if(type == 1){  // 值为1是我的应用
                    [mineData addObject:dict];
                } else {    // 值为2、3是其他应用
                    [otherData addObject:dict];
                }
                [allData addObject:dict];
            }else{
                [subData addObject:dict];
            }
            [searchData addObject:dict];
        }
        
        // 对我的应用进行排序
        [self sortWithArray:mineData key:@"userappsort" ascending:YES];
        
        // 对其他应用进行分组排序
        NSMutableArray *allGroupData = [self groupWithArray:allData];
        
        // 对子应用进行排序
        [self sortWithArray:subData key:@"appsort" ascending:YES];
        
        // 最终数据（写入SandBox的数据）[第一级主应用]
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:mineData, @"mineData", otherData, @"otherData", allGroupData, @"allGroupData", allData, @"allData", nil];
        [self writeAppData:dataDict];
        
        // 最终数据（写入SandBox的数据）[子类应用]
        NSMutableDictionary *subDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subData, @"subAppData", nil];
        [self writeAppSubData:subDataDict];
        
        // 最终数据（写入SandBox的数据）[搜索应用]
        NSMutableDictionary *searchDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:searchData, @"searchAppData", nil];
        [self writeAppSearchData:searchDataDict];
        
        success(dataDict);
    } failure:^(NSString *error) {
        failure(error);
    } invalid:^(NSString *msg) {
        invalid(msg);
    }];
    
}

// 对数据进行分组排序
- (NSMutableArray *)groupWithArray:(NSArray *)array {
    NSMutableArray *newArray = [NSMutableArray array];
    for(NSDictionary *appDict in array){
        NSString * groupName = [appDict objectForKey:@"grouptypename"];
        if (!groupName) {
            groupName = @"更多应用";
        }
        NSMutableDictionary *groupDict = [self searchGroupWithName:groupName groupArray:newArray];
        if (!groupDict) {
            groupDict = [NSMutableDictionary dictionary];
            [groupDict setValue:groupName forKey:@"groupName"];
            [groupDict setValue:appDict[@"grouptypesort"] forKey:@"groupSort"];
            [groupDict setValue:appDict[@"grouptypecode"] forKey:@"groupCode"];
            [groupDict setValue:[NSMutableArray array] forKey:@"appArray"];
            [newArray addObject:groupDict];
        }
        NSMutableArray *appArray = [groupDict objectForKey:@"appArray"];
        [appArray addObject:appDict];
    }
    // 分组排序
    [self sortWithArray:newArray key:@"groupSort" ascending:YES];
    // 组内排序
    for (NSDictionary *groupDict in newArray) {
        NSMutableArray *appArray = [groupDict objectForKey:@"appArray"];
        [self sortWithArray:appArray key:@"appsort" ascending:YES];
    }
    return newArray;
}

- (NSMutableDictionary *)searchGroupWithName:(NSString *)groupName groupArray:(NSMutableArray *)groupArray {
    for (NSMutableDictionary *dict in groupArray) {
        if ([dict[@"groupName"] isEqualToString:groupName]) {
            return dict;
        }
    }
    return nil;
    
}

- (NSMutableArray *)loadSubDataWithPno:(NSString *)pno level:(NSString *)level {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *subAppDict = [[BaseSandBoxUtil sharedBaseSandBoxUtil] loadDataWithFileName:APP_SUB_FILE];
    NSArray *subAppData = [subAppDict objectForKey:@"subAppData"];
    for(NSDictionary *dict in subAppData){
        NSString *pappno = [dict objectForKey:@"pappno"];
        NSString *applevel = [dict objectForKey:@"applevel"];
        if([pno isEqualToString:pappno] && [level isEqualToString:applevel]){
            AppModelItem *item = [AppModelItem createWithDictionary:dict];
            [mutableArray addObject:item];
        }
    }
    
    return mutableArray;
}

- (NSMutableArray *)loadSearchData {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *searchAppDict = [[BaseSandBoxUtil sharedBaseSandBoxUtil] loadDataWithFileName:APP_SEARCH_FILE];
    NSArray *searchAppData = [searchAppDict objectForKey:@"searchAppData"];
    for(NSDictionary *dict in searchAppData){
        AppModelItem *item = [AppModelItem createWithDictionary:dict];
        [mutableArray addObject:item];
    }
    
    return mutableArray;
}

// 向服务器保存自定义app排序
- (void)saveCustomData:(NSArray *)customData
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSString *error))failure
               invalid:(void (^)(NSString *msg))invalid
{
    NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
    
    int appsort = 0;
    for(NSDictionary *dict in customData){
        appsort ++;
        NSString *appno = [dict objectForKey:@"appno"];
        NSString *apptype = [dict objectForKey:@"apptype"];
        
        NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:appsort], @"appsort", appno, @"appno", apptype, @"apptype", nil];
        
        [paramsArray addObject:paramDict];
    }
    
    NSDictionary *param = @{@"msg":paramsArray};//格式化参数
    [YZNetworkingManager POST:@"app/saveCustomAppSort" parameters:param success:^(id responseObject) {
        DLog(@"保存成功！");
        success(responseObject);
    } failure:^(NSString *error) {
        DLog(@"同步保存数据失败...");
        failure(error);
    } invalid:^(NSString *msg) {
        DLog(@"同步保存数据失败...");
        invalid(msg);
    }];
    
}

// 写入应用数据到本地SandBox中
- (BOOL)writeAppData:(NSDictionary *)appData{
    return [[BaseSandBoxUtil sharedBaseSandBoxUtil] writeData:appData fileName:APP_FILE];
}

// 子类信息写入应用数据到本地SandBox中
- (BOOL)writeAppSubData:(NSDictionary *)appData{
    return [[BaseSandBoxUtil sharedBaseSandBoxUtil] writeData:appData fileName:APP_SUB_FILE];
}

// 应用搜索信息写入本地SandBox中
- (BOOL)writeAppSearchData:(NSDictionary *)appData{
    return [[BaseSandBoxUtil sharedBaseSandBoxUtil] writeData:appData fileName:APP_SEARCH_FILE];
}

// 私有为NSMutableArray排序方法
- (void)sortWithArray:(NSMutableArray *)array key:(NSString *)key ascending:(BOOL)ascending{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
