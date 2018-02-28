/************************************************************
 Class    : AppBorderView.h
 Describe : 自定义应用列表底部虚线视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AppBorderType) {
    AppBorderTypeDashed,
    AppBorderTypeTypeSolid
};

@interface AppBorderView : UIView
{
    CAShapeLayer *_shapeLayer;
    AppBorderType _borderType;
    CGFloat _cornerRadius;
    CGFloat _borderWidth;
    NSUInteger _dashPattern;
    NSUInteger _spacePattern;
    UIColor *_borderColor;
}

@property (assign ,nonatomic) AppBorderType borderType;
@property (assign ,nonatomic) CGFloat cornerRadius;
@property (assign ,nonatomic) CGFloat borderWidth;
@property (assign ,nonatomic) NSUInteger dashPattern;
@property (assign ,nonatomic) NSUInteger spacePattern;
@property (strong ,nonatomic) UIColor *borderColor;

@end
