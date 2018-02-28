/************************************************************
 Class    : MapListModel.m
 Describe : 地图机构模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MapListModel.h"

@implementation MapListModel

+ (MapListModel *)createWithJSON:(id)json {
    MapListModel *model = [super yy_modelWithJSON:json];
    return model;
}

+ (MapListModel *)createWithDictionary:(NSDictionary *)dictionary {
    MapListModel *model = [super yy_modelWithDictionary:dictionary];
    model.level = model.level-1;
    if(model.level == 0){
        model.isExpand = YES;
    }else{
        model.isExpand = NO;
    }
    return model;
}
/*
model.parentCode = [dict objectForKey:@"AREAFATHERID"];
model.nodeCode = [dict objectForKey:@"AREAID"];
model.level = [[dict objectForKey:@"LEVELS"] integerValue]-1;
model.name = [dict objectForKey:@"AREANAME"];
model.deptName = [dict objectForKey:@"TAXDEPTNAME"];
model.address = [dict objectForKey:@"ADDRESS"];
model.tel = [dict objectForKey:@"PHONE"];
model.latitude = [dict objectForKey:@"LAT"];
model.longitude = [dict objectForKey:@"WARP"];
if(model.level == 0){
    model.isExpand = YES;
}else{
    model.isExpand = NO;
}
*/
/*
 * 该方法是“字典里的属性Key”和“要转化为模型里的属性名”不一样，而重写的
 * 前：模型的属性   后：字典里的属性
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"parentCode":@"AREAFATHERID",
             @"nodeCode":@"AREAID",
             @"level":@"LEVELS",
             @"name":@"AREANAME",
             @"deptName":@"TAXDEPTNAME",
             @"address":@"ADDRESS",
             @"tel":@"PHONE",
             @"latitude":@"LAT",
             @"longitude":@"WARP"
             };
}

@end
