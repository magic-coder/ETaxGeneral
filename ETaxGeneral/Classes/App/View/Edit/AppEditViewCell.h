/************************************************************
 Class    : AppEditViewCell.h
 Describe : 自定义应用管理编辑模块视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class AppModelItem;

// 自定义编辑按钮样式
typedef NS_ENUM(NSInteger, AppCellEditBtnStyle) {
    AppCellEditBtnStyleAdd,     // 编辑按钮为添加
    AppCellEditBtnStyleDelete,  // 编辑按钮为删除
    AppCellEditBtnStyleSelected // 编辑按钮为已选择
};

@protocol AppEditViewCellDelegate <NSObject>

@optional
-(void)appEditViewCellEditBtnClick:(UIButton *)sender;

@end

@interface AppEditViewCell : UICollectionViewCell

@property (nonatomic, assign) AppCellEditBtnStyle editBtnStyle;  // 编辑按钮样式

@property (nonatomic, strong) AppModelItem *item;

@property (nonatomic, weak) id<AppEditViewCellDelegate> delegate;

@end
