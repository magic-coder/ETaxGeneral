/************************************************************
 Class    : AppModel.h
 Describe : 应用列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface AppModelItem : NSObject

/************************ 属性 ************************/
@property (nonatomic, strong) NSString *no;         // 应用NO
@property (nonatomic, strong) NSString *pno;        // 应用父PNO
@property (nonatomic, strong) NSString *level;      // 应用级别
@property (nonatomic, strong) NSString *title;      // 应用名称
@property (nonatomic, strong) NSString *webImg;     // 服务器应用图标
@property (nonatomic, strong) NSString *localImg;   // 本地默认logo
@property (nonatomic, strong) NSString *url;        // 应用链接URL（Web应用）
@property (nonatomic, assign) BOOL isNewApp;        // 是否新App
@property (nonatomic, strong) NSString *keyWords;   // 检索关键词

/************************ 类方法 ************************/
+ (AppModelItem *)createWithJSON:(id)json;
+ (AppModelItem *)createWithDictionary:(NSDictionary *)dictionary;

@end

@interface AppModelGroup : NSObject

/************************ 属性 ************************/
// 组标题
@property (nonatomic, strong) NSString *groupTitle;
// 组元素
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign, readonly) NSUInteger itemsCount;

/************************ 类方法 ************************/
- (AppModelGroup *) initWithGroupTitle:(NSString *)groupTitle settingItems:(AppModelItem *)firstObj, ...;
- (AppModelItem *) itemAtIndex:(NSUInteger)index;
- (NSUInteger) itemsCount;

@end
