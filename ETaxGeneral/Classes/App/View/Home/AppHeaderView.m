/************************************************************
 Class    : AppHeaderView.m
 Describe : 自定义应用列表分组栏头视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppHeaderView.h"

@interface AppHeaderView ()

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation AppHeaderView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        if(DEVICE_SCREEN_INCH_IPAD){
            _titleFont = [UIFont systemFontOfSize:16.0f];
        }else{
            _titleFont = [UIFont systemFontOfSize:14.0f];
        }
        
        [self addSubview:self.colorView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark - 布局方法
- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - 分组标题左侧色块视图
-(UIView *)colorView {
    if(!_colorView){
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(8, 14, 5, 12)];
        _colorView.backgroundColor = DEFAULT_BLUE_COLOR;
    }
    return _colorView;
}

#pragma mark - 分组标题组件
- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, self.frameHeight-20, self.frameWidth * 0.3f, 20)];
        _titleLabel.font = _titleFont;
        _titleLabel.textColor = [UIColor grayColor];
    }
    return _titleLabel;
}

#pragma mark - 设置标题title
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = _title;
    
    [self layoutSubviews];
}

@end
