/************************************************************
 Class    : BaseHandleUtil.m
 Describe : 基本的通用工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-25
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseHandleUtil.h"
#import "MainTabBarController.h"

#import <EventKit/EventKit.h>
//#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SNOW_IMAGE_X                arc4random()%(int)WIDTH_SCREEN
#define SNOW_IMAGE_ALPHA            ((float)(arc4random()%10))/10 + 0.5f
#define SNOW_IMAGE_WIDTH            arc4random()%20 + 20

@interface BaseHandleUtil()

// 下雪效果
@property (nonatomic, strong) NSMutableArray *snowImagesArray;
@property (nonatomic, strong) NSTimer *snowTimer;

@end

@implementation BaseHandleUtil

#pragma mark - 单例模式方法
SingletonM(BaseHandleUtil)

#pragma mark - 获取当前设备基本信（存放本地对象中）
- (void)currentDeviceInfo {
    
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];                                                       // 设备主键（唯一）
    NSString *deviceName = [[UIDevice currentDevice] name];                                                                                         // 设备名称
    NSString *deviceModel = [[UIDevice currentDevice] deviceModelName];                                                                             // 设备型号
    NSString *deviceInch = [NSString stringWithFormat:@"%d*%d", (int)WIDTH_SCREEN, (int)HEIGHT_SCREEN ];                                            // 设备尺寸
    NSString *systemVersion = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]]; // 系统版本

    NSDictionary *deviceDict = [NSDictionary dictionaryWithObjectsAndKeys:deviceIdentifier, @"deviceIdentifier", deviceName, @"deviceName", deviceModel, @"deviceModel", deviceInch, @"deviceInch", systemVersion, @"systemVersion", nil];
    
    DLog(@"设备基本信息：");
    DLog(@"设备主键：%@", deviceIdentifier);
    DLog(@"设备名称：%@", deviceName);
    DLog(@"设备型号：%@", deviceModel);
    DLog(@"设备尺寸：%@", deviceInch);
    DLog(@"系统版本：%@", systemVersion);
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceDict forKey:DEVICE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize]; // 强制写入
    
}

#pragma mark - 获取当前最顶端展示的视图控制器
#pragma mark 获取当前显示的视图（主方法）
- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[WINDOW rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

#pragma mark 获取当前展示的视图控制器（递归调用方法）
- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

#pragma mark - 读取程序中的JSON文件数据转换为OC对象
- (id)readWithJSONFile:(NSString *)file {
    
    NSString *fileName = [file stringByDeletingPathExtension];
    NSString *fileType = [file pathExtension];
    
    // JSON文件的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    // 读取JSON文件
    NSData *data = [NSData dataWithContentsOfFile:path];
    // 将JSON数据转为NSArray或NSDictionary（调用本类中已经写好的方法）
    id object = [self objectWithJSONData:data];
    return object;
}

#pragma mark - 将OC对象转换为NSData
- (NSData *)dataWithObject:(id)object {
    if(object) {
        NSData *data= [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        return data;
    }else{
        DLog(@"object为空，无法转换，返回nil");
        return nil;
    }
}

#pragma mark - 将JSON转换为OC对象
- (id)objectWithJSONData:(id)data {
    if(data) {
        // 将JSON数据转为NSArray或NSDictionary
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        return object;
    }else{
        DLog(@"data为空，无法转换，返回nil");
        return nil;
    }
}

#pragma mark - 将OC对象转换为JSON字符串
- (NSString *)JSONStringWithObject:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if(jsonData){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        DLog(@"JSON 转换失败 error : %@",error);
    }
    
    return jsonString;
}

#pragma mark - 计算文本所需的宽高
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}

#pragma mark - 计算文本在label中的高度
- (CGFloat)calculateHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font {
    static UILabel *stringLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{    //生成一个同于计算文本高度的label
        stringLabel = [UILabel new];
        stringLabel.numberOfLines = 0;
    });
    stringLabel.font = font;
    stringLabel.attributedText = GetAttributedText(text);
    return [stringLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
}
#pragma mark - 计算文本在label中需要的高度
NSMutableAttributedString *GetAttributedText(NSString *value) {//这里调整富文本的段落格式
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:value];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8.0];
    // [paragraphStyle setParagraphSpacing:11]; //调整段间距
    // [paragraphStyle setHeadIndent:75.0];//段落整体缩进
    // [paragraphStyle setFirstLineHeadIndent:.0];//首行缩进
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [value length])];
    return attributedString;
}

#pragma mark - 中文转换拼音
- (NSString *)transform:(NSString *)chinese {
    // 去掉空格
    NSString *trimChinese = [chinese stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // 转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:trimChinese];
    // 先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    // 再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    // 转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    NSArray *pinYins = [pinYin componentsSeparatedByString:@" "];
    NSString *initial = @"";
    for(NSString *letter in pinYins){
        initial = [NSString stringWithFormat:@"%@%@", initial, [letter substringToIndex:1]];
    }
    // 获取并返回首字母
    return initial;
}

#pragma mark - 获取系统当前时间
- (NSString *)currentDateTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:[NSDate date]];
}

#pragma mark - App事件添加到系统日历提醒事项，实现日程提醒功能
- (void)createEventCalendarTitle:(NSString *)title
                        location:(NSString *)location
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate
                           notes:(NSString *)notes
                          allDay:(BOOL)allDay
                      alarmArray:(NSArray *)alarmArray
                           block:(void (^)(NSString *))block {
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    // 检索提醒事件是否存在
    /*
     NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:[eventStore calendarsForEntityType:EKEntityTypeEvent]];
     NSArray *eventArray = [eventStore eventsMatchingPredicate:predicate];
     if(eventArray){
     block(@"该提醒已经添加，请进入\"日历\"查看！");
     }
     */
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    block(@"添加失败，请稍后重试！");
                }else if (!granted){
                    block(@"不允许使用日历,请在设置中允许此App使用日历！");
                }else{
                    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
                    event.title = [NSString stringWithFormat:@"%@：%@", [Variable sharedVariable].appName, title];
                    event.location = location;
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.startDate = startDate;
                    event.endDate   = endDate;
                    event.allDay = allDay;
                    event.notes  = notes;
                    
                    //添加提醒
                    if (alarmArray && alarmArray.count > 0) {
                        for (NSString *timeString in alarmArray) {
                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
                        }
                    }
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    // 已添加到系统日历中！
                    block(@"success");
                    
                }
            });
        }];
    }
    
}

#pragma mark - 播放本地音频文件（老方法，不支持音量大小控制）
 - (void)playSoundEffect:(NSString *)name
 type:(NSString *)type {
 // 1.得到音效文件的地址
 NSString *soundFilePath =[[NSBundle mainBundle] pathForResource:name ofType:type];
 // 2.将地址字符串转换成url
 NSURL *soundURL = [NSURL fileURLWithPath:soundFilePath];
 // 3.生成系统音效id
 SystemSoundID soundFileObject;
 AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundFileObject);
 // 4.播放系统音效
 AudioServicesPlaySystemSound(soundFileObject);
 }
#pragma mark - 播放本地音频文件（新方法，支持音量控制）
/*
- (void)playSoundEffect:(NSString *)name
                   type:(NSString *)type {
    // 1.得到音效文件的地址
    NSString *soundFilePath =[[NSBundle mainBundle] pathForResource:name ofType:type];
    // 2.将地址字符串转换成url
    NSURL *soundURL = [NSURL fileURLWithPath:soundFilePath];
    // 3.初始化音频播放器
    AVAudioPlayer *avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    // 4.设置循环播放
    // 设置循环播放的次数
    // 循环次数 = 0，声音会播放一次
    // 循环次数 = 1，声音会播放2次
    // 循环次数小于0，会无限循环播放，如：-1
    avAudioPlayer.numberOfLoops = 0;
    // 5.设置音量
    avAudioPlayer.volume = 1;
    // 6.准备播放
    [avAudioPlayer prepareToPlay];
    // 7.开始播放
    [avAudioPlayer play];
}
 */

#pragma mark - 节日动画下落效果（下雪、红包、福袋...）
#pragma mark 初始化雪花效果
- (void)snowAnimation {
    
    [self snowTimerRelease];
    [self snowClean];
    
    _snowImagesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; ++ i) {
        // common_snow、common_red_packet
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_snow"]];
        float x = SNOW_IMAGE_WIDTH;
        imageView.frame = CGRectMake(SNOW_IMAGE_X, -40, x, x);
        imageView.alpha = SNOW_IMAGE_ALPHA;
        //[self.view addSubview:imageView];
        [WINDOW addSubview:imageView];
        [_snowImagesArray addObject:imageView];
    }
    self.snowTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(makeSnow) userInfo:nil repeats:YES];
}
#pragma mark 制作雪花
static int i = 0;
- (void)makeSnow {
    i = i + 1;
    if ([_snowImagesArray count] > 0) {
        UIImageView *imageView = [_snowImagesArray objectAtIndex:0];
        imageView.tag = i;
        [_snowImagesArray removeObjectAtIndex:0];
        [self snowFall:imageView count:_snowImagesArray.count];
    }else{
        [self snowTimerRelease];
    }
}
#pragma mark 雪花下落效果
- (void)snowFall:(UIImageView *)aImageView count:(NSInteger)count {
    [UIView beginAnimations:[NSString stringWithFormat:@"%li",(long)aImageView.tag] context:nil];
    [UIView setAnimationDuration:6];
    [UIView setAnimationDelegate:self];
    aImageView.frame = CGRectMake(aImageView.frame.origin.x, HEIGHT_SCREEN, aImageView.frameWidth, aImageView.frameHeight);
    [UIView commitAnimations];
    if(count == 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self snowClean];
        });
    }
}
#pragma mark 结束雪花动画，释放对象
- (void)snowClean {
    // 创建前先移除以前的
    if(![self.snowTimer isValid]){
        //NSArray *subViews = [self.view subviews];
        NSArray *subViews = [WINDOW subviews];
        for(UIView *view in subViews){
            if([view isKindOfClass:[UIImageView class]] && (view.originY == -40 || view.originY == HEIGHT_SCREEN)){
                [view removeFromSuperview];
            }
        }
    }
}
#pragma mark 停止下雪特效的计时器
- (void)snowTimerRelease {
    // 释放定时器，销毁 timer
    if([self.snowTimer isValid]){
        [self.snowTimer invalidate];
        self.snowTimer = nil;
    }   
}

#pragma mark - 设置未读消息条数角标提醒
- (void)msgBadge:(int)badge {
    // 设置app角标(若为0则系统会自动清除角标)
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    
    MainTabBarController *mainTabBarController = [MainTabBarController sharedMainTabBarController];
    // 设置tabBar消息角标
    if(badge > 0){
        [mainTabBarController.tabBar.items objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%d", badge];
    }else{
        [mainTabBarController.tabBar.items objectAtIndex:2].badgeValue = nil;
    }
}

@end
