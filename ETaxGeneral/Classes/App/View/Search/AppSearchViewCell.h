/************************************************************
 Class    : AppSearchViewCell.h
 Describe : 搜索列表cell样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-23
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class AppModelItem;

typedef NS_ENUM(NSInteger, AppSearchViewCellLineStyle) {
    AppSearchViewCellLineStyleDefault,
    AppSearchViewCellLineStyleFill,
    AppSearchViewCellLineStyleNone,
};

@interface AppSearchViewCell : UITableViewCell

@property (nonatomic, assign) AppSearchViewCellLineStyle bottomLineStyle;
@property (nonatomic, assign) AppSearchViewCellLineStyle topLineStyle;

@property (nonatomic, strong) AppModelItem *item;
@property (nonatomic, strong) UILabel *titleLabel;   // 名称

@end
