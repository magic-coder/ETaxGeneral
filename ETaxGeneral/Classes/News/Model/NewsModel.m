/************************************************************
 Class    : NewsModel.m
 Describe : 首页新闻展示数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "NewsModel.h"

@implementation NewsModel

+ (NewsModel *)createWithJSON:(id)json {
    NewsModel *model = [super yy_modelWithJSON:json];
    
    switch (model.images.count) {
        case 0:
            model.style = NewsModelStyleText;
            break;
        case 1:
            //model.style = NewsModelStyleOneImage;
            model.style = NewsModelStyleFewImage;
            break;
        case 2:
            model.style = NewsModelStyleFewImage;
            break;
        default:
            model.style = NewsModelStyleMoreImage;
            break;
    }
    
    return model;
}

+ (NewsModel *)createWithDictionary:(NSDictionary *)dictionary {
    NewsModel *model = [super yy_modelWithDictionary:dictionary];
    
    switch (model.images.count) {
        case 0:
            model.style = NewsModelStyleText;
            break;
        case 1:
            //model.style = NewsModelStyleOneImage;
            model.style = NewsModelStyleFewImage;
            break;
        case 2:
            model.style = NewsModelStyleFewImage;
            break;
        default:
            model.style = NewsModelStyleMoreImage;
            break;
    }
    
    return model;
}

/*
 * 该方法是“字典里的属性Key”和“要转化为模型里的属性名”不一样，而重写的
 * 前：模型的属性   后：字典里的属性
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"title":@"TITLE",
             @"showTitle":@"SHOWTITLE",
             @"images":@"IMAGES",
             //@"source":@"SOURCE",
             @"datetime":@"RELEASEDATE",
             @"url":@"URL"
             };
}

@end
