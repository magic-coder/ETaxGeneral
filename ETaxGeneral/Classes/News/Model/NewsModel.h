/************************************************************
 Class    : NewsModel.h
 Describe : 首页新闻展示数据模型
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

#pragma mark 新闻样式ENUM
typedef NS_ENUM(NSInteger, NewsModelStyle) {
    NewsModelStyleText,     // 纯文本的新闻类型样式
    NewsModelStyleOneImage, // 只有一张图片的样式，显示一张大图
    NewsModelStyleFewImage, // 图片大于1张小于3张的新闻类型样式
    NewsModelStyleMoreImage // 图片大于等于3张的新闻类型样式
};

@interface NewsModel : NSObject

/************************ 属性 ************************/
@property (nonatomic, strong) NSString *title;          // 标题
@property (nonatomic, strong) NSString *showTitle;      // 显示标题
@property (nonatomic, strong) NSArray *images;          // 图片（以数组的形式存放）
@property (nonatomic, strong) NSString *source;         // 来源（如：来自地税、国税、其他等...）
@property (nonatomic, strong) NSString *datetime;       // 发布时间
@property (nonatomic, strong) NSString *url;            // 详情url

@property (nonatomic, assign) CGFloat cellHeight;       // cell高度
@property (nonatomic, assign) NewsModelStyle style;     // 样式

/************************ 类方法 ************************/
+ (NewsModel *)createWithJSON:(id)json;
+ (NewsModel *)createWithDictionary:(NSDictionary *)dictionary;

@end
