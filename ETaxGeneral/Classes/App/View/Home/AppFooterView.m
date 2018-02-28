/************************************************************
 Class    : AppFooterView.h
 Describe : 自定义应用列表分组底部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppFooterView.h"

@interface AppFooterView ()

@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@property (nonatomic, strong) UILabel *msgLabel;

@end

@implementation AppFooterView

#pragma mark - 初始化方法
-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.leftLine];
        [self addSubview:self.rightLine];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (UIView *)leftLine {
    if(!_leftLine){
        _leftLine = [[UIView alloc] initWithFrame:CGRectMake(20, 10, self.frameWidth/4, 0.5f)];
        _leftLine.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    }
    return _leftLine;
}

- (UIView *)rightLine {
    if(!_rightLine){
        _rightLine = [[UIView alloc] initWithFrame:CGRectMake(self.frameRight-self.frameWidth/4-20, 10, self.frameWidth/4, 0.5f)];
        _rightLine.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    }
    return _rightLine;
}

-(UILabel *)msgLabel {
    if(!_msgLabel){
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frameWidth/2-self.frameWidth/4/2, 0, self.frameWidth/4, 20)];
        _msgLabel.textColor = DEFAULT_LINE_GRAY_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        if(DEVICE_SCREEN_INCH_IPAD){
            _msgLabel.font = [UIFont systemFontOfSize:14.0f];
        }else{
            _msgLabel.font = [UIFont systemFontOfSize:12.0f];
        }
        _msgLabel.text = @"这是我的底线了";
    }
    return _msgLabel;
}

@end
