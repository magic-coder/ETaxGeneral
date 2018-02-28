/************************************************************
 Class    : MapViewController.h
 Describe : 地图展示视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class MapListModel;

@interface MapViewController : BaseViewController

@property(nonatomic, strong) MapListModel *model;

@end
