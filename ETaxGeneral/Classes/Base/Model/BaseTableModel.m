/************************************************************
 Class    : BaseTableModel.m
 Describe : 基本的表格模型对象
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseTableModel.h"

#pragma mark - BaseTableModelItem方法
@implementation BaseTableModelItem

#pragma mark 初始化方法
- (instancetype) init{
    if (self = [super init]) {
        self.alignment = BaseTableModelItemAlignmentRight;
        
        self.bgColor = [UIColor whiteColor];
        self.titleColor = [UIColor blackColor];
        self.subTitleColor = [UIColor grayColor];
        self.titleFont = [UIFont systemFontOfSize:17.0f];
        self.subTitleFont = [UIFont systemFontOfSize:15.0f];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.rightImageHeightOfCell = 0.72f;
        self.middleImageHeightOfCell = 0.35f;
    }
    return self;
}
#pragma mark 创建item的各种方法
+ (BaseTableModelItem *) createWithTitle:(NSString *)title{
    return [BaseTableModelItem createWithImageName:nil title:title];
}

+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title{
    return [BaseTableModelItem createWithImageName:imageName title:title subTitle:nil rightImageName:nil];
}

+ (BaseTableModelItem *) createWithTitle:(NSString *)title subTitle:(NSString *)subTitle{
    return [BaseTableModelItem createWithImageName:nil title:title subTitle:subTitle rightImageName:nil];
}

+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title middleImageName:(NSString *)middleImageName subTitle:(NSString *)subTitle{
    return [BaseTableModelItem createWithImageName:imageName title:title middleImageName:middleImageName subTitle:subTitle rightImageName:nil];
}

+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title subTitle:(NSString *)subTitle rightImageName:(NSString *)rightImageName{
    return [BaseTableModelItem createWithImageName:imageName title:title middleImageName:nil subTitle:subTitle rightImageName:rightImageName];
}

+ (BaseTableModelItem *) createWithImageName:(NSString *)imageName title:(NSString *)title middleImageName:(NSString *)middleImageName subTitle:(NSString *)subTitle rightImageName:(NSString *)rightImageName{
    BaseTableModelItem *item = [[BaseTableModelItem alloc] init];
    item.imageName = imageName;
    item.middleImageName = middleImageName;
    item.rightImageName = rightImageName;
    item.title = title;
    item.subTitle = subTitle;
    return item;
}

#pragma mark - 设置对齐方式
- (void) setAlignment:(BaseTableModelItemAlignment)alignment{
    _alignment = alignment;
    if (alignment == BaseTableModelItemAlignmentMiddle) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - 设置类型
- (void) setType:(BaseTableModelItemType)type{
    _type = type;
    if (type == BaseTableModelItemTypeSwitch) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (type == BaseTableModelItemTypeButton) {
        self.btnBGColor = DEFAULT_BLUE_COLOR;
        self.btnTitleColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bgColor = [UIColor clearColor];
    }
}

@end

#pragma mark - BaseTableModelGroup方法
@implementation BaseTableModelGroup

#pragma mark 初始化一个组
- (instancetype) initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle settingItems:(BaseTableModelItem *)firstObj, ...{
    if (self = [super init]) {
        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
        _items = [[NSMutableArray alloc] init];
        va_list argList;
        if (firstObj) {
            [_items addObject:firstObj];
            va_start(argList, firstObj);
            id arg;
            while ((arg = va_arg(argList, id))) {
                [_items addObject:arg];
            }
            va_end(argList);
        }
    }
    return self;
}

#pragma mark 根据下标获取对象
- (BaseTableModelItem *) itemAtIndex:(NSUInteger)index{
    return [_items objectAtIndex:index];
}

#pragma mark 获取每组中对象的个数
- (NSUInteger) itemsCount{
    return self.items.count;
}

@end
