/************************************************************
 Class    : MapListViewCell.h
 Describe : 自定义地图机构列表Cell
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class MapListModel;

@interface MapListViewCell : UITableViewCell

@property (nonatomic, strong) MapListModel *model;

@end
