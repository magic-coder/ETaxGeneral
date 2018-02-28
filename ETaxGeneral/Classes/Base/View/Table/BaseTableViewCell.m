/************************************************************
 Class    : BaseTableViewCell.m
 Describe : 基本的表格cell视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseTableViewCell.h"
#import "BaseTableModel.h"

@interface BaseTableViewCell()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, assign) float leftFreeSpace;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *middleImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UISwitch *cSwitch;
@property (nonatomic, strong) UIButton *cButton;

@property (nonatomic, strong) NSMutableArray *subImageArray;

@end

@implementation BaseTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _topLineStyle = CellLineStyleNone;
        _bottomLineStyle = CellLineStyleDefault;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.subTitleLabel];
        
        [self addSubview:self.mainImageView];
        [self addSubview:self.middleImageView];
        [self addSubview:self.rightImageView];
        
        [self addSubview:self.cSwitch];
        [self addSubview:self.cButton];
    }
    return self;
}

#pragma mark - 初始化样式
- (void) layoutSubviews{
    [super layoutSubviews];
    
    [self.topLine setOriginY:0];
    [self.bottomLine setOriginY:self.frameHeight - _bottomLine.frameHeight];
    [self setBottomLineStyle:_bottomLineStyle];
    [self setTopLineStyle:_topLineStyle];
    
    self.leftFreeSpace = self.frameWidth * 0.05;
    float spaceX = self.leftFreeSpace;
    
    if (self.item.type == BaseTableModelItemTypeButton) {
        float buttonX = self.frameWidth * 0.04;
        float buttonY = self.frameHeight * 0.09;
        float buttonWidth = self.frameWidth - buttonX * 2;
        float buttonHeight = self.frameHeight - buttonY * 2;
        [self.cButton setFrame:CGRectMake(buttonX, 0, buttonWidth, buttonHeight)];
        return;
    }
    
    float x = spaceX;
    float y = self.frameHeight * 0.22;
    float h = self.frameHeight - y * 2;
    y -= 0.25;      // 补线高度差
    CGSize size;
    
    // Main Image
    if (self.item.imageName) {
        [self.mainImageView setFrame:CGRectMake(x, y, h, h)];
        x += h + spaceX;
    }
    // Title
    if (self.item.title) {
        size = [self.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        if (self.item.alignment == BaseTableModelItemAlignmentMiddle) {
            [self.titleLabel setFrame:CGRectMake((self.frameWidth - size.width) * 0.5, y, size.width, h)];
        }
        else {
            [self.titleLabel setFrame:CGRectMake(x, y - 0.5, size.width, h)];
        }
    }
    
    if (self.item.alignment == BaseTableModelItemAlignmentRight) {
        float rx = self.frameWidth - (self.item.accessoryType == UITableViewCellAccessoryDisclosureIndicator ? 35 : 10);
        
        if (self.item.type == BaseTableModelItemTypeSwitch) {
            float cx = rx - self.cSwitch.frameWidth / 1.7;
            [self.cSwitch setCenter:CGPointMake(cx, self.frameHeight / 2.0)];
            rx -= self.cSwitch.frameWidth - 5;
        }
        
        if (self.item.rightImageName) {
            float mh = self.frameHeight * self.item.rightImageHeightOfCell;
            float my = (self.frameHeight - mh) / 2;
            rx -= mh;
            [self.rightImageView setFrame:CGRectMake(rx, my, mh, mh)];
            rx -= mh * 0.15;
        }
        if (self.item.subTitle) {
            size = [self.subTitleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            rx -= size.width;
            [self.subTitleLabel setFrame:CGRectMake(rx, y - 0.5, size.width, h)];
            rx -= 5;
        }
        if (self.item.middleImageName) {
            float mh = self.frameHeight * self.item.middleImageHeightOfCell;
            float my = (self.frameHeight - mh) / 2 - 0.5;
            rx -= mh;
            [self.middleImageView setFrame:CGRectMake(rx, my, mh, mh)];
            rx -= mh * 0.15;
        }
    }
    else if (self.item.alignment == BaseTableModelItemAlignmentLeft) {
        float t = 105;
        if (DEVICE_SCREEN_INCH_5_5) {
            t = 120;
        }
        float lx = (x < t ? t : x);
        if (self.item.subTitle) {
            size = [self.subTitleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            [self.subTitleLabel setFrame:CGRectMake(lx, y - 0.5, size.width, h)];
            lx += size.width + 5;
        }
        else if (self.item.subImages && self.item.subImages.count > 0) {
            float imageWidth = self.frameHeight * 0.65;
            float width = self.frameWidth * 0.89 - lx;
            float space = 0;
            NSUInteger count = width / imageWidth * 1.1;
            count = count < self.subImageArray.count ? count : self.subImageArray.count;
            for (int i = 0; i < count; i ++) {
                UIButton *iV = [self.subImageArray objectAtIndex:i];
                [iV setFrame:CGRectMake(lx + (imageWidth + space) * i, (self.frameHeight - imageWidth) / 2, imageWidth, imageWidth)];
                space = imageWidth * 0.1;
            }
            for (int i = (int)count; i < self.item.subImages.count; i ++) {
                UIButton *iV = [self.subImageArray objectAtIndex:i];
                [iV removeFromSuperview];
            }
        }
    }
    
}

#pragma mark - 重写item的Setter方法
- (void) setItem:(BaseTableModelItem *)item{
    _item = item;
    
    // 设置数据
    if (item.type == BaseTableModelItemTypeButton) {
        [self.cButton setTitle:item.title forState:UIControlStateNormal];
        [self.cButton setBackgroundColor:item.btnBGColor];
        [self.cButton setTitleColor:item.btnTitleColor forState:UIControlStateNormal];
        [self.cButton setHidden:NO];
        [self.titleLabel setHidden:YES];
        [self.cButton setTag:item.tag];
    }else {
        [self.cButton setHidden:YES];
        [self.titleLabel setText:item.title];
        [self.titleLabel setHidden:NO];
    }
    
    if (item.subTitle) {
        [self.subTitleLabel setText:item.subTitle];
        [self.subTitleLabel setHidden:NO];
    }else {
        [self.subTitleLabel setHidden:YES];
    }
    
    if (item.imageName) {
        [self.mainImageView setImage:[UIImage imageNamed:item.imageName]];
        [self.mainImageView setHidden:NO];
    }else {
        [self.middleImageView setImage:nil];
        [self.mainImageView setHidden:YES];
    }
    
    if (item.middleImageName) {
        [self.middleImageView setImage:[UIImage imageNamed:item.middleImageName]];
        [self.middleImageView setHidden:NO];
    }else {
        [self.middleImageView setImage:nil];
        [self.middleImageView setHidden:YES];
    }
    
    if (item.rightImageName) {
        [self.rightImageView setImage:[UIImage imageNamed:item.rightImageName]];
        [self.rightImageView setHidden:NO];
    }else {
        [self.rightImageView setImage:nil];
        [self.rightImageView setHidden:YES];
    }
    
    if (item.type == BaseTableModelItemTypeSwitch) {
        [self.cSwitch setHidden:NO];
        [self.cSwitch setTag:item.tag];
        if(item.isOn){
            self.cSwitch.on = YES;
        }else{
            self.cSwitch.on = NO;
        }
    }else {
        [self.cSwitch setHidden:YES];
    }
    
    if (item.subImages) {
        for (int i = 0; i < item.subImages.count; i++) {
            id imageName = item.subImages[i];
            UIButton *button = nil;
            if (i < self.subImageArray.count) {
                button = self.subImageArray[i];
            }else {
                button = [[UIButton alloc] init];
                [self.subImageArray addObject:button];
            }
            
            if ([imageName isKindOfClass:[NSString class]]) {
                [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            }
            [self addSubview:button];
        }
        
        for (int i = (int)(item.subImages.count); i < self.subImageArray.count; i ++) {
            UIButton *button = self.subImageArray[i];
            [button removeFromSuperview];
        }
    }
    // 设置样式
    [self setBackgroundColor:item.bgColor];
    [self setAccessoryType:item.accessoryType];
    [self setSelectionStyle:item.selectionStyle];
    
    [self.titleLabel setFont:item.titleFont];
    [self.titleLabel setTextColor:item.titleColor];
    
    [self.subTitleLabel setFont:item.subTitleFont];
    [self.subTitleLabel setTextColor:item.subTitleColor];
    
    [self layoutSubviews];
}

#pragma mark - 根据text的值计算获得高度
+ (CGFloat) getHeightForText:(BaseTableModelItem *)item{
    
    float defaultH = 43.0f, buttonH = 50.0f, subH = 86.0f;
    
    if(DEVICE_SCREEN_INCH_IPAD){    // 适配iPad端
        defaultH = 50.0f;
        buttonH = 58.0f;
        subH = 92.0f;
    }
    
    if (item.type == BaseTableModelItemTypeButton) {
        return buttonH;
    }else if (item.subImages && item.subImages.count > 0) {
        return subH;
    }else{
        return defaultH;
    }
}

#pragma mark - Getter
- (UILabel *) titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        //[_titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    }
    return _titleLabel;
}

- (UILabel *) subTitleLabel{
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        //[_subTitleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    }
    return _subTitleLabel;
}

- (UIImageView *) mainImageView{
    if (_mainImageView == nil) {
        _mainImageView = [[UIImageView alloc] init];
    }
    return _mainImageView;
}

- (UIImageView *) middleImageView{
    if (_middleImageView == nil) {
        _middleImageView = [[UIImageView alloc] init];
    }
    return _middleImageView;
}

- (UIImageView *) rightImageView{
    if (_rightImageView == nil) {
        _rightImageView = [[UIImageView alloc] init];
    }
    return _rightImageView;
}

- (NSMutableArray *) subImageArray{
    if (_subImageArray == nil) {
        _subImageArray = [[NSMutableArray alloc] init];
    }
    return _subImageArray;
}

- (UISwitch *) cSwitch{
    if (_cSwitch == nil) {
        _cSwitch = [[UISwitch alloc] init];
        [_cSwitch addTarget:self action:@selector(cSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _cSwitch;
}

- (UIButton *) cButton{
    if (_cButton == nil) {
        _cButton = [[UIButton alloc] init];
        [_cButton.layer setMasksToBounds:YES];
        [_cButton.layer setCornerRadius:4.0f];
        [_cButton.layer setBorderColor:DEFAULT_LINE_GRAY_COLOR.CGColor];
        [_cButton.layer setBorderWidth:0.5f];
        [_cButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        // 注册按钮点击事件
        [self.cButton addTarget:self action:@selector(cButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cButton;
}

#pragma mark - 自身代理方法
- (void)cSwitchChanged:(UISwitch *)sender{
    // 如果协议响应了baseTableViewCellSwitchChanged方法
    if([_delegate respondsToSelector:@selector(baseTableViewCellSwitchChanged:)]){
        [_delegate baseTableViewCellSwitchChanged:sender]; // 通知执行协议方法
    }
}

- (void)cButtonOnClick:(UIButton *)sender{
    // 如果协议响应了baseTableViewCellBtnClick方法
    if([_delegate respondsToSelector:@selector(baseTableViewCellBtnClick:)]){
        [_delegate baseTableViewCellBtnClick:sender]; // 通知执行协议方法
    }
}

#pragma mark - CommonMethod
- (UIView *) topLine{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        [_topLine setFrameHeight:0.5f];
        [_topLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
        //[_topLine setAlpha:0.4];
        [self.contentView addSubview:_topLine];
    }
    return _topLine;
}

- (UIView *) bottomLine{
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        [_bottomLine setFrameHeight:0.5f];
        [_bottomLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
        //[_bottomLine setAlpha:0.4];
        [self.contentView addSubview:_bottomLine];
    }
    return _bottomLine;
}

- (void) setTopLineStyle:(CellLineStyle)style{
    _topLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.topLine setOriginX:_leftFreeSpace];
        [self.topLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.topLine setHidden:NO];
    }else if (style == CellLineStyleFill) {
        [self.topLine setOriginX:0];
        [self.topLine setFrameWidth:self.frameWidth];
        [self.topLine setHidden:NO];
    }else if (style == CellLineStyleNone) {
        [self.topLine setHidden:YES];
    }
}

- (void) setBottomLineStyle:(CellLineStyle)style{
    _bottomLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.bottomLine setOriginX:_leftFreeSpace];
        [self.bottomLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.bottomLine setHidden:NO];
    }else if (style == CellLineStyleFill) {
        [self.bottomLine setOriginX:0];
        [self.bottomLine setFrameWidth:self.frameWidth];
        [self.bottomLine setHidden:NO];
    }else if (style == CellLineStyleNone) {
        [self.bottomLine setHidden:YES];
    }
}

@end
