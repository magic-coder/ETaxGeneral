/************************************************************
 Class    : UIDevice+YZ.h
 Describe : 自定义UIDevice的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

// 定义屏幕尺寸枚举类型
/*
typedef NS_ENUM(NSInteger, DeviceScreenInch){
    // iPhone 尺寸
    DeviceScreenInch_3_5,   // 3.5英寸    320*480 (4、4s)
    DeviceScreenInch_4_0,   // 4.0英寸    320*568 (5、5s、5se)
    DeviceScreenInch_4_7,   // 4.7英寸    375*667 (6、6s、7、8)
    DeviceScreenInch_5_5,   // 5.5英寸    414*736 (6 plus、6s plus、7 plus、8 plus)
    DeviceScreenInch_5_8,   // 5.8英寸    375*812 (X)

    // iPad 尺寸
    DeviceScreenInch_iPad,   // 7.9英寸/9.7英寸（768*1024）、10.5英寸（834*1112）、12.9英寸（1024*1366）
};
*/

@interface UIDevice (YZ)

// 获取具体设备型号
- (NSString *)deviceModelName;

// 获取设备屏幕尺寸
//- (DeviceScreenInch)deviceScreenInch;

@end
