/************************************************************
 Class    : AppView.m
 Describe : 自定义应用列表视样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppView.h"
#import "AppModel.h"

@interface AppView ()

@property (nonatomic, assign) float imgWH;                  // 图标的尺寸
@property (nonatomic, assign) float titleHeight;            // 标题高度
@property (nonatomic, strong) UIFont *titleFont;            // 标题字体

@property (nonatomic, strong) UIImageView *newsImageView;   // 新角标
@property (nonatomic, strong) UIImageView *imageView;       // 图片视图

@end

@implementation AppView

#pragma mark - 初始化创建方法
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        
        if(DEVICE_SCREEN_INCH_IPAD){
            _imgWH = 32.0f;
            _titleHeight = 24.0f;
            _titleFont = [UIFont systemFontOfSize:16.0f];
        }else{
            _imgWH = 27.0f;
            _titleHeight = 20.0f;
            _titleFont = [UIFont systemFontOfSize:13.0f];
        }
        
        // 添加UIView点击事件
        UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAction:)];
        [self addGestureRecognizer:tapGesturRecognizer];
        
        [self initialeze];
    }
    return self;
}

#pragma mark - 添加UIView的点击事件（代理方法）
- (void)onClickAction:(UITapGestureRecognizer *)sender {
    // 如果协议响应了appViewClick方法
    if([_delegate respondsToSelector:@selector(appViewClick:)]){
        [_delegate appViewClick:(AppView *)sender.view]; // 通知执行协议方法
    }
}

#pragma mark - 初始化方法
- (void)initialeze {
    self.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    
}

#pragma mark - 设置布局样式
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 如果image存在，进行设置图片的样式
    if(self.item.webImg || self.item.localImg){
        [_imageView setFrame:CGRectMake(self.frameWidth*0.5f-_imgWH*0.5f, self.frameHeight*0.5f-_imgWH*0.7f, _imgWH, _imgWH)];
        [_imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    // 如果title存在，进行设置标签的样式
    if(self.item.title){
        [_titleLabel setFrame:CGRectMake(0, self.frameHeight*0.7f, self.frameWidth-0.5f, _titleHeight)];
        [_titleLabel setFont:_titleFont];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor lightGrayColor]];
    }
    
}

#pragma mark - 重写item的Setter方法
- (void)setItem:(AppModelItem *)item {
    _item = item;
    // 从远程URL获取图片(默认本地图标)
    [_imageView sd_setImageWithURL:[NSURL URLWithString:item.webImg] placeholderImage:[UIImage imageNamed:item.localImg] options:SDWebImageAllowInvalidSSLCertificates completed:nil];
    _titleLabel.text = self.item.title;
    
    [self layoutSubviews];
}

@end
