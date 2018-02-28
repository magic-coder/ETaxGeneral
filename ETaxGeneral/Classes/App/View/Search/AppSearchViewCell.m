/************************************************************
 Class    : AppSearchViewCell.m
 Describe : 搜索列表cell样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-23
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppSearchViewCell.h"
#import "AppModel.h"

@interface AppSearchViewCell ()

@property (nonatomic, assign) float leftFreeSpace;
@property (nonatomic, assign) float imageWH;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIView *topLine;      // 顶部线条
@property (nonatomic, strong) UIView *bottomLine;   // 底部线条

@property (nonatomic, strong) UIImageView *logoView; // 图标

@end

@implementation AppSearchViewCell

#pragma mark - 初始化加载
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _topLineStyle = AppSearchViewCellLineStyleNone;
        _bottomLineStyle = AppSearchViewCellLineStyleDefault;
        
        self.leftFreeSpace = 12.0f;
        self.imageWH = 42.0f;
        self.titleFont = [UIFont systemFontOfSize:17.0f];
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.logoView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.topLine];
        [self addSubview:self.bottomLine];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.topLine setOriginY:0];
    [self.bottomLine setOriginY:self.frameHeight - _bottomLine.frameHeight];
    [self setBottomLineStyle:_bottomLineStyle];
    [self setTopLineStyle:_topLineStyle];
    
    float space = self.leftFreeSpace;
    [_logoView setFrame:CGRectMake(space, space-2, self.imageWH, self.imageWH)];
    
    float labelX = space * 2 + self.imageWH;
    float labelY = self.frameHeight * 0.3;
    float labelHeight = self.frameHeight * 0.4;
    float labelWidth = self.frameWidth - labelX - space * 2;
    [_titleLabel setFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
}

#pragma mark - 重写Setter方法
- (UIView *) topLine{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        [_topLine setFrameHeight:0.5f];
        [_topLine setBackgroundColor:[UIColor grayColor]];
        [_topLine setAlpha:0.4];
        [self.contentView addSubview:_topLine];
    }
    return _topLine;
}

- (UIView *) bottomLine{
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        [_bottomLine setFrameHeight:0.5f];
        [_bottomLine setBackgroundColor:[UIColor grayColor]];
        [_bottomLine setAlpha:0.4];
        [self.contentView addSubview:_bottomLine];
    }
    return _bottomLine;
}

- (void) setTopLineStyle:(AppSearchViewCellLineStyle)style{
    _topLineStyle = style;
    if (style == AppSearchViewCellLineStyleDefault) {
        [self.topLine setOriginX:_leftFreeSpace];
        [self.topLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.topLine setHidden:NO];
    }else if (style == AppSearchViewCellLineStyleFill) {
        [self.topLine setOriginX:0];
        [self.topLine setFrameWidth:self.frameWidth];
        [self.topLine setHidden:NO];
    }else if (style == AppSearchViewCellLineStyleNone) {
        [self.topLine setHidden:YES];
    }
}

- (void) setBottomLineStyle:(AppSearchViewCellLineStyle)style{
    _bottomLineStyle = style;
    if (style == AppSearchViewCellLineStyleDefault) {
        [self.bottomLine setOriginX:_leftFreeSpace];
        [self.bottomLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.bottomLine setHidden:NO];
    }else if (style == AppSearchViewCellLineStyleFill) {
        [self.bottomLine setOriginX:0];
        [self.bottomLine setFrameWidth:self.frameWidth];
        [self.bottomLine setHidden:NO];
    }else if (style == AppSearchViewCellLineStyleNone) {
        [self.bottomLine setHidden:YES];
    }
}

- (void)setItem:(AppModelItem *)item {
    _item = item;
    
    // 从远程地址获取logo图
    [_logoView sd_setImageWithURL:[NSURL URLWithString:_item.webImg] placeholderImage:[UIImage imageNamed:_item.localImg] options:SDWebImageAllowInvalidSSLCertificates completed:nil];
    //[_logoView setImage:[UIImage imageNamed:_item.localImg]];
    [_titleLabel setText:_item.title];
    
    [self layoutSubviews];
}

#pragma mark - 重写Getter方法
- (UIImageView *)logoView{
    if (_logoView == nil) {
        _logoView = [[UIImageView alloc] init];
        [_logoView.layer setMasksToBounds:YES];
        [_logoView.layer setCornerRadius:5.0f];
    }
    return _logoView;
}

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = self.titleFont;
    }
    return _titleLabel;
}

@end
