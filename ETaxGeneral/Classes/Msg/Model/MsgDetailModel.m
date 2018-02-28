/************************************************************
 Class    : MsgDetailModel.m
 Describe : 消息明细列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MsgDetailModel.h"

@implementation MsgDetailModel

+ (MsgDetailModel *)createWithJSON:(id)json {
    MsgDetailModel *model = [MsgDetailModel yy_modelWithJSON:json];
    return model;
}

+ (MsgDetailModel *)createWithDictionary:(NSDictionary *)dictionary {
    MsgDetailModel *model = [MsgDetailModel yy_modelWithDictionary:dictionary];
    
    model.date = [[dictionary objectForKey:@"pushdate"] substringWithRange:NSMakeRange(0, 19)];
    return model;
}

/*
 * 该方法是“字典里的属性Key”和“要转化为模型里的属性名”不一样，而重写的
 * 前：模型的属性   后：字典里的属性
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"uuid":@"pushdetailuuid",
             @"title":@"pushtitle",
             @"user":@"taxofficialname",
             //@"date":@"pushdate",
             @"content":@"pushcontent",
             @"url":@"detailurl"
             };
}

@end
