/************************************************************
 Class    : MapListUtil.h
 Describe : 地图机构工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MapListUtil : NSObject

SingletonH(MapListUtil)

- (NSMutableArray *)loadMapData;

- (void)initMapDataSuccess:(void (^)(NSMutableArray *dataArray))success
                   failure:(void(^)(NSString *error))failure
                   invalid:(void (^)(NSString *msg))invalid;

@end
