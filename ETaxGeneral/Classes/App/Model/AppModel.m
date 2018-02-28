/************************************************************
 Class    : AppModel.m
 Describe : 应用列表数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppModel.h"

#pragma mark - 应用模型Item方法
@implementation AppModelItem

#pragma mark 根据JSON创建一个item
+ (AppModelItem *)createWithJSON:(id)json {
    AppModelItem *item = [super yy_modelWithJSON:json];
    return item;
}

#pragma mark 根据字典创建一个item
+ (AppModelItem *)createWithDictionary:(NSDictionary *)dictionary {
    AppModelItem *item = [super yy_modelWithDictionary:dictionary];
    
    if([item.level isEqualToString:@"0"]){
        item.localImg = [NSString stringWithFormat:@"app_%@", item.no]; // 加载本地default图标(根据应用序列号生成)
    }else{
        item.localImg = [NSString stringWithFormat:@"app_%@%@", item.pno, item.no]; // 加载本地default图标(根据应用序列号生成)
    }
    
    if([[dictionary objectForKey:@"isnewapp"] isEqualToString:@"Y"]){
        item.isNewApp = YES;
    }else{
        item.isNewApp = NO;
    }
    
    if(!item.url){
        item.url = @"";
    }
    
    item.keyWords = [NSString stringWithFormat:@"%@ %@", item.title, [[BaseHandleUtil sharedBaseHandleUtil] transform:item.title]];
    return item;
}

/*
 * 该方法是“字典里的属性Key”和“要转化为模型里的属性名”不一样，而重写的
 * 前：模型的属性   后：字典里的属性
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"no":@"appno",
             @"pno":@"pappno",
             @"level":@"applevel",
             @"title":@"appname",
             @"webImg":@"appimage",
             @"url":@"appurl"
             };
}

@end

#pragma mark - 应用模型Group方法
@implementation AppModelGroup

#pragma mark 初始化方法
- (AppModelGroup *)initWithGroupTitle:(NSString *)groupTitle settingItems:(AppModelItem *)firstObj, ... {
    AppModelGroup *group = [[AppModelGroup alloc] init];
    group.groupTitle = groupTitle;
    group.items = [[NSMutableArray alloc] init];
    va_list argList;
    if (firstObj) {
        [group.items addObject:firstObj];
        va_start(argList, firstObj);
        id arg;
        while ((arg = va_arg(argList, id))) {
            [group.items addObject:arg];
        }
        va_end(argList);
    }
    return group;
}

#pragma mark 根据下标获取对象
- (AppModelItem *)itemAtIndex:(NSUInteger)index{
    return [_items objectAtIndex:index];
}

#pragma mark 获取每个组中对象的个数
- (NSUInteger) itemsCount{
    return self.items.count;
}

@end
