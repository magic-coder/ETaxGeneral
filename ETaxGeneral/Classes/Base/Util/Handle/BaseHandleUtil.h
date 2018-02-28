/************************************************************
 Class    : BaseHandleUtil.h
 Describe : 基本的通用工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-25
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

@interface BaseHandleUtil : NSObject

// 单例模式方法
SingletonH(BaseHandleUtil)

/**
 *  获取当前设备的基本信息
 */
- (void)currentDeviceInfo;

/**
 *  获取当前最顶端展示的视图控制器
 *
 *  @return 正在显示的视图控制器ViewController
 */
- (UIViewController *)topViewController;

/**
 *  读取程序中的JSON文件数据转换为OC对象
 *
 *  @param  file    程序中JSON文件名称
 *
 *  @return OC对象（NSArray、NSDictionary）
 */
- (id)readWithJSONFile:(NSString *)file;

/**
 *  将JSON转换为OC对象
 *
 *  @param  object    需要转换的OC对象（NSArray、NSDictionary）数据
 *
 *  @return NSData类型数据
 */
- (NSData *)dataWithObject:(id)object;

/**
 *  将JSON转换为OC对象
 *
 *  @param  data    需要转换的JSONData数据
 *
 *  @return OC对象（NSArray、NSDictionary）
 */
- (id)objectWithJSONData:(NSData *)data;

/**
 *  将OC对象转换为JSON
 *
 *  @param  object  需要转换的对象（NSArray、NSDictionary）
 *
 *  @return NSString类型的JSON字符串
 */
- (NSString *)JSONStringWithObject:(id)object;

/**
 *  计算文本所需的宽高
 *
 *  @param  str      需要计算的文本
 *  @param  font     文本显示的字体
 *  @param  maxSize  文本显示的范围
 *
 *  @return 文本实际所需的高度
 */
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 * 计算文本在Label中所需的高度
 *
 * @param   text    要计算的文本内容
 * @param   width   宽度
 * @param   font    字体
 *
 * @return  所需的高度
 */
- (CGFloat)calculateHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;

/**
 *  获取关键字，中文转换拼音
 *
 *  @param  chinese  需要转换的中文
 *
 *  @return 转换后的拼音关键词
 */
- (NSString *)transform:(NSString *)chinese;

/**
 * 获取系统当前时间
 *
 * @return 格式为 yyyy-MM-dd HH:mm:ss 的时间
 */
- (NSString *)currentDateTime;

/**
 *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 *
 *  @param title      事件标题
 *  @param location   事件位置
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 *  @param block      回调方法
 */
- (void)createEventCalendarTitle:(NSString *)title 
                        location:(NSString *)location
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate
                           notes:(NSString *)notes
                          allDay:(BOOL)allDay
                      alarmArray:(NSArray *)alarmArray
                           block:(void(^)(NSString *msg))block;

/**
 * 播放本地自定义声音
 *
 * @param name  音频文件名称
 * @param type  音频类型
 */
- (void)playSoundEffect:(NSString *)name
                   type:(NSString *)type;

/**
 * 节日动画下落效果（下雪、红包、福袋...）
 */
- (void)snowAnimation;

/**
 * 设置未读消息条数角标提醒
 *
 * @param badge 未读消息条数
 */
- (void)msgBadge:(int)badge;

@end
