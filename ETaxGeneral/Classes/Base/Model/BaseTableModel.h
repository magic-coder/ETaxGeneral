/************************************************************
 Class    : BaseTableModel.h
 Describe : 基本的表格模型对象
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <Foundation/Foundation.h>

#pragma mark - 自定义枚举类型
#pragma mark 对齐方式ENUM
typedef NS_ENUM(NSInteger, BaseTableModelItemAlignment) {
    BaseTableModelItemAlignmentLeft,
    BaseTableModelItemAlignmentRight,
    BaseTableModelItemAlignmentMiddle
};

#pragma mark 类型ENUM
typedef NS_ENUM(NSInteger, BaseTableModelItemType) {
    BaseTableModelItemTypeDefault,       // image, title, rightTitle, rightImage
    BaseTableModelItemTypeButton,        // button
    BaseTableModelItemTypeSwitch        // title， switch
};

#pragma mark - 条目定义对象
@interface BaseTableModelItem : NSObject

// 对齐方式
@property (nonatomic, assign) BaseTableModelItemAlignment alignment;
// 类型
@property (nonatomic, assign) BaseTableModelItemType type;


/************************ 属性 ************************/
// 1 主图片， 左边
@property (nonatomic, strong) NSString *imageName;
//@property (nonatomic, strong) NSURL *imageURL;
// 2 主标题
@property (nonatomic, strong) NSString *title;
// 3.1 中间图片
@property (nonatomic, strong) NSString *middleImageName;
//@property (nonatomic, assign) NSURL *middlerImageURL;
// 3.2 图片集
@property (nonatomic, strong) NSArray *subImages;
// 4 副标题
@property (nonatomic, strong) NSString *subTitle;
// 5 右图片
@property (nonatomic, strong) NSString *rightImageName;
//@property (nonatomic, strong) NSURL *rightImageURL;
// 6 btton、switch的标签tag
@property (nonatomic, assign) NSInteger tag;
// 7 设置switch的值
@property (nonatomic, assign) BOOL isOn;


/************************ 样式 ************************/
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *btnBGColor;
@property (nonatomic, strong) UIColor *btnTitleColor;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIColor *subTitleColor;
@property (nonatomic, strong) UIFont *subTitleFont;

@property (nonatomic, assign) CGFloat rightImageHeightOfCell;
@property (nonatomic, assign) CGFloat middleImageHeightOfCell;


/************************ 类方法 ************************/
+ (BaseTableModelItem *) createWithTitle:(NSString *)title;
+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title;
+ (BaseTableModelItem *) createWithTitle:(NSString *)title subTitle:(NSString *)subTitle;
+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title middleImageName:(NSString *)middleImageName subTitle:(NSString *)subTitle;
+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title subTitle:(NSString *)subTitle rightImageName:(NSString *)rightImageName;
+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title middleImageName:(NSString *)middleImageName subTitle:(NSString *)subTitle rightImageName:(NSString *)rightImageName;

@end

#pragma mark - 组定义对象
@interface BaseTableModelGroup : NSObject

/************************ 属性 ************************/
// 组头部标题
@property (nonatomic, strong) NSString *headerTitle;
// 组尾部说明
@property (nonatomic, strong) NSString *footerTitle;
// 组元素
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign, readonly) NSUInteger itemsCount;


/************************ 类方法 ************************/
- (instancetype) initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle settingItems:(BaseTableModelItem *)firstObj, ...;
- (BaseTableModelItem *) itemAtIndex:(NSUInteger)index;

@end
