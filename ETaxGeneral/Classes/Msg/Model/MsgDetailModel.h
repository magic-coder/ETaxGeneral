/************************************************************
 Class    : MsgDetailModel.h
 Describe : 消息明细列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MsgDetailModel : NSObject

/************************ 属性 ************************/
@property (nonatomic, strong) NSString *uuid;       // 消息主键
@property (nonatomic, strong) NSString *title;      // 标题
@property (nonatomic, strong) NSString *user;       // 标题
@property (nonatomic, strong) NSString *date;       // 时间
@property (nonatomic, strong) NSString *content;    // 内容
@property (nonatomic, strong) NSString *url;        // 详情页

@property (nonatomic, assign) CGFloat cellHeight;   // cell高度

/************************ 类方法 ************************/
+ (MsgDetailModel *)createWithJSON:(id)json;
+ (MsgDetailModel *)createWithDictionary:(NSDictionary *)dictionary;

@end
