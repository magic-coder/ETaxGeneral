/************************************************************
 Class    : MineHeaderView.h
 Describe : 我的界面顶部头视图展示基本信息
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
#import "YZButton.h"

// 设置accountHeaderView点击的代理方法
@protocol MineHeaderViewDelegate <NSObject>

@optional
- (void)mineHeaderViewBtnDidSelected:(UIButton *)sender;

@end

@interface MineHeaderView : UIView

@property (nonatomic, strong) UIImageView *imageView;           // 背景图
@property (nonatomic, strong) UIImageView *accountImageView;    // 用户头像视图
@property (nonatomic, strong) UIButton *nightShiftBtn;          // 夜间模式按钮
@property (nonatomic, strong) UIButton *accountBtn;             // 用户信息按钮
@property (nonatomic, strong) UILabel *levelLabel;              // 用户等级
@property (nonatomic, strong) UILabel *nameLabel;               // 用户名称
@property (nonatomic, strong) UILabel *orgNameLabel;            // 机构名称

@property (nonatomic, strong) UIView *bottomView;               // 底部操作视图

@property (nonatomic, strong) YZButton *leftBtn;                // 左边按钮
@property (nonatomic, strong) YZButton *middleBtn;              // 中间按钮
@property (nonatomic, strong) YZButton *rightBtn;               // 右边按钮

@property (nonatomic, strong) UIView *firstLineView;            // 第一条竖线
@property (nonatomic, strong) UIView *secondLineView;           // 第二条竖线

@property (nonatomic, strong) UIView *topLineView;              // 底部视图最上方横线
@property (nonatomic, strong) UIView *bottomLineView;           // 底部视图最下方横线

@property (nonatomic, strong) NSString *nameText;               // 名字

@property (nonatomic, weak) id<MineHeaderViewDelegate> delegate;

@end
