/************************************************************
 Class    : MsgListModel.h
 Describe : 消息分组列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MsgListModel : NSObject

/************************ 属性 ************************/
@property (nonatomic, strong) NSString *sourceCode;     // 来源代码
@property (nonatomic, strong) NSString *pushOrgCode;    // 推送机构代码
@property (nonatomic, strong) NSString *avatar;         // 头像
@property (nonatomic, strong) NSString *name;           // 名称
@property (nonatomic, strong) NSString *message;        // 消息
@property (nonatomic, strong) NSString *date;           // 时间
@property (nonatomic, strong) NSString *unReadCount;    // 未读条数

/************************ 类方法 ************************/
+ (MsgListModel *)createWithJSON:(id)json;
+ (MsgListModel *)createWithDictionary:(NSDictionary *)dictionary;

@end
