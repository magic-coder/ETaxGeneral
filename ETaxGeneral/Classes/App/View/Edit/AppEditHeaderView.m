/************************************************************
 Class    : AppEditHeaderView.m
 Describe : 自定义应用管理编辑模块组视图栏
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppEditHeaderView.h"

@interface AppEditHeaderView ()

@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *titleLabel;      // 标签
@property (nonatomic, strong) UIFont *titleFont;

@end

@implementation AppEditHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initialize];
    }
    return self;
}

#pragma mark - 初始化方法
- (void)initialize{
    
    self.backgroundColor = [UIColor whiteColor];
    
    if(DEVICE_SCREEN_INCH_IPAD){
        _titleFont = [UIFont systemFontOfSize:16.0f];
    }else{
        _titleFont = [UIFont systemFontOfSize:14.0f];
    }
    
    [self addSubview:self.colorView];
    
    [self addSubview:self.titleLabel];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 如果标题存在，进行设置标签样式
    if(self.title){
        // float x = self.frameWidth * 0.035;
        float w = self.frameWidth * 0.89;
        float h = [[BaseHandleUtil sharedBaseHandleUtil] calculateHeightWithText:self.title width:w font:_titleFont];
        float x = 16.0f;
        [_titleLabel setFrame:CGRectMake(x, self.frameHeight/2-h/2, w, h)];
        // 居中布局
        //[_titleLabel setFrame:CGRectMake(self.frameWidth/2-size.width/2, self.frameHeight/2-size.height/2, w, size.height)];
    }
}

#pragma mark - 重写Getter用于组件初始化方法
- (UIView *)colorView {
    if(!_colorView){
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 10.0f, 5.0f, 12.0f)];
        _colorView.backgroundColor = DEFAULT_BLUE_COLOR;
    }
    return _colorView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        
        [_titleLabel setNumberOfLines:0];// 自动换行
        [_titleLabel setTextColor:[UIColor grayColor]];
        [_titleLabel setFont:_titleFont];
    }
    return _titleLabel;
}

#pragma mark - 重写text的Setter方法
- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleLabel setText:_title];
    
    [self layoutSubviews];
}

@end
