/************************************************************
 Class    : BaseTableViewHeaderFooterView.m
 Describe : 基本的表格头部、底部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseTableViewHeaderFooterView.h"

static UILabel *hLabel = nil;

@interface BaseTableViewHeaderFooterView()

@property (nonatomic, strong) UILabel *titleLabel;  // 标题标签

@end

@implementation BaseTableViewHeaderFooterView

- (instancetype) initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setUserInteractionEnabled:NO];
        [self addSubview:self.titleLabel];
        [self setBackgroundView:[[UIView alloc] init]];
    }
    return self;
}

#pragma mark - 初始化样式
- (void) layoutSubviews{
    [super layoutSubviews];
    
    float x = self.frameWidth * 0.065;
    float w = self.frameWidth * 0.89;
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(w, MAXFLOAT)];
    [self.titleLabel setFrame:CGRectMake(x, 6, w, size.height)];
}

#pragma mark - 重写text的Setter方法
- (void) setText:(NSString *)text{
    _text = text;
    [self.titleLabel setText:text];
    [self layoutSubviews];
}

#pragma mark - 根据text来计算高度
+ (CGFloat) getHeightForText:(NSString *)text{
    if (text == nil) {
        return 20.0f;
    }
    if (hLabel == nil) {
        hLabel = [[UILabel alloc] init];
        [hLabel setNumberOfLines:0];
        if(DEVICE_SCREEN_INCH_IPAD){
            [hLabel setFont:[UIFont systemFontOfSize:16.0f]];
        }else{
            [hLabel setFont:[UIFont systemFontOfSize:14.0f]];
        }
    }
    [hLabel setText:text];
    float w = WIDTH_SCREEN * 0.92;
    float h = [hLabel sizeThatFits:CGSizeMake(w, MAXFLOAT)].height + 14.0f;
    if(DEVICE_SCREEN_INCH_IPAD)
        h = [hLabel sizeThatFits:CGSizeMake(w, MAXFLOAT)].height + 16.0f;
    return h;
}

#pragma mark - Getter
- (UILabel *) titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:[UIColor grayColor]];
        [_titleLabel setNumberOfLines:0];
        if(DEVICE_SCREEN_INCH_IPAD){
            [_titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        }else{
            [_titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        }
    }
    return _titleLabel;
}

@end
