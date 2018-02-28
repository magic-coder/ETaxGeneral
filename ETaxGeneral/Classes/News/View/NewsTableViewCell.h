/************************************************************
 Class    : NewsTableViewCell.h
 Describe : 首页新闻展示自定义TableViewCell样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class NewsModel;

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;

@end
