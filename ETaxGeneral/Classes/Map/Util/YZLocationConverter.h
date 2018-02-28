/************************************************************
 Class    : YZLocationConverter.h
 Describe : 自定义地图坐标转换类
            WGS-84：是国际标准，GPS坐标（Google Earth使用、或者GPS模块）
            GCJ-02：中国坐标偏移标准，Google地图、高德、腾讯使用
            BD-09 ：百度坐标偏移标准，Baidu地图使用
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-11
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YZLocationConverter : NSObject

/**
 *	@brief	世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  ####只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
 *
 *	@param 	location 	世界标准地理坐标(WGS-84)
 *
 *	@return	中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location;


/**
 *	@brief	中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *	@param 	location 	中国国测局地理坐标（GCJ-02）
 *
 *	@return	世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location;


/**
 *	@brief	世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 *
 *	@param 	location 	世界标准地理坐标(WGS-84)
 *
 *	@return	百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location;


/**
 *	@brief	中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 *
 *	@param 	location 	中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *	@return	百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location;


/**
 *	@brief	百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *	@param 	location 	百度地理坐标（BD-09)
 *
 *	@return	中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location;


/**
 *	@brief	百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *	@param 	location 	百度地理坐标（BD-09)
 *
 *	@return	世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location;

@end
