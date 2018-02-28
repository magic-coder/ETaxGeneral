/************************************************************
 Class    : RouteAnnotation.h
 Describe : 地图线路规划
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-11
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface RouteAnnotation : BMKPointAnnotation

///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点  6:楼梯、电梯
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger degree;

//获取该RouteAnnotation对应的BMKAnnotationView
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview;

@end
