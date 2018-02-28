/************************************************************
 Class    : AppSubViewCell.h
 Describe : 第二级菜单列表自定义cell样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-09
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class AppModelItem;

typedef NS_ENUM(NSInteger, AppSubViewCellLineStyle) {
    AppSubViewCellLineStyleDefault,
    AppSubViewCellLineStyleFill,
    AppSubViewCellLineStyleNone,
};

@interface AppSubViewCell : UITableViewCell

@property (nonatomic, assign) AppSubViewCellLineStyle bottomLineStyle;
@property (nonatomic, assign) AppSubViewCellLineStyle topLineStyle;

@property (nonatomic, strong) AppModelItem *item;
@property (nonatomic, strong) UILabel *titleLabel;   // 名称

@end
