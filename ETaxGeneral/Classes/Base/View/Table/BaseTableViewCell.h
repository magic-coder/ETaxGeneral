/************************************************************
 Class    : BaseTableViewCell.h
 Describe : 基本的表格cell视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class BaseTableModelItem;

typedef NS_ENUM(NSInteger, CellLineStyle) {
    CellLineStyleDefault,
    CellLineStyleFill,
    CellLineStyleNone,
};

@protocol BaseTableViewCellDelegate <NSObject>

- (void)baseTableViewCellBtnClick:(UIButton *)sender;   // 按钮点击代理方法
- (void)baseTableViewCellSwitchChanged:(UISwitch *)sender;  // Switch开关变更方法

@end

@interface BaseTableViewCell :UITableViewCell

@property (nonatomic, assign) CellLineStyle bottomLineStyle;    // 底部线条样式
@property (nonatomic, assign) CellLineStyle topLineStyle;       // 顶部线条样式


@property (nonatomic, strong) BaseTableModelItem *item;

+(CGFloat)getHeightForText:(BaseTableModelItem *)item;

@property (nonatomic, weak) id<BaseTableViewCellDelegate> delegate;

@end
