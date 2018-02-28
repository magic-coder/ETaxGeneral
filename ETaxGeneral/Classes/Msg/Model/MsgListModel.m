/************************************************************
 Class    : MsgListModel.m
 Describe : 消息分组列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MsgListModel.h"

@implementation MsgListModel

+ (MsgListModel *)createWithJSON:(id)json {
    MsgListModel *model = [super yy_modelWithJSON:json];
    return model;
}

+ (MsgListModel *)createWithDictionary:(NSDictionary *)dictionary {
    MsgListModel *model = [super yy_modelWithDictionary:dictionary];
    
    if([model.sourceCode isEqualToString:@"01"]){     // 一般用户推送
        model.avatar = @"msg_information";
        model.name = [dictionary objectForKey:@"swjgjc"];
    }else{
        model.avatar = @"msg_notification";
        model.name = [dictionary objectForKey:@"sourcename"];
    }
    
    model.date = [model.date substringWithRange:NSMakeRange(0, 16)];
    
    return model;
}

/*
 * 该方法是“字典里的属性Key”和“要转化为模型里的属性名”不一样，而重写的
 * 前：模型的属性   后：字典里的属性
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"sourceCode":@"sourcecode",
             @"pushOrgCode":@"swjgdm",
             @"message":@"pushcontent",
             @"date":@"pushdate",
             @"unReadCount":@"unreadcount"
             };
}

@end
