/************************************************************
 Class    : AppEditViewCell.m
 Describe : 自定义应用管理编辑模块视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppEditViewCell.h"
#import "AppModel.h"

@interface AppEditViewCell ()

@property (nonatomic, assign) float baseSpace;              // 基本的间距
@property (nonatomic, assign) float imgWH;                  // 图标大小
@property (nonatomic, assign) float editBtnWH;              // 编辑按钮的尺寸
@property (nonatomic, assign) float titleH;                 // 标题高度
@property (nonatomic, strong) UIFont *titleFont;            // 标题字体大小
@property (nonatomic, assign) float newImageWH;             // New图标尺寸

@property (nonatomic, strong) UIView *topLine;              // 顶部边线
@property (nonatomic, strong) UIView *leftLine;             // 左侧边线
@property (nonatomic, strong) UIView *rightLine;            // 右侧边线
@property (nonatomic, strong) UIView *bottomLine;           // 底部边线

@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *imageView;       // 图片视图

@property (nonatomic, strong) UIButton *editBtn;            // 右上角编辑按钮
@property (nonatomic, strong) UIImageView *newsImageView;   // 新角标

@end

@implementation AppEditViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self initialize];
    }
    return self;
}

#pragma mark - 初始化方法
- (void)initialize{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    if(DEVICE_SCREEN_INCH_IPAD){
        _baseSpace = 8.0f;
        _imgWH = 32.0f;
        _editBtnWH = 34.0f;
        _titleH = 24.0f;
        _titleFont = [UIFont systemFontOfSize:16.0f];
        
        _newImageWH = 32.0f;
    }else{
        _baseSpace = 5.0f;
        _imgWH = 27.0f;
        _editBtnWH = 30.0f;
        _titleH = 20.0f;
        _titleFont = [UIFont systemFontOfSize:13.0f];
        
        _newImageWH = 28.0f;
    }
    
    _topLine = [[UIView alloc] init];
    [self.contentView addSubview:_topLine];
    
    _leftLine = [[UIView alloc] init];
    [self.contentView addSubview:_leftLine];
    
    _rightLine = [[UIView alloc] init];
    [self.contentView addSubview:_rightLine];
    
    _bottomLine = [[UIView alloc] init];
    [self.contentView addSubview:_bottomLine];
    
    _imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_titleLabel];
    
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_editBtn];
    
    // 新角标
    _newsImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_newsImageView];
}

#pragma mark - 设置布局样式
- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 顶部边线样式
    [_topLine setFrame:CGRectMake(_baseSpace, _baseSpace, self.frameWidth-0.5f-(_baseSpace*2), 0.5f)];
    [_topLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    _topLine.alpha = 0.6f;
    
    // 左侧边线样式
    [_leftLine setFrame:CGRectMake(_baseSpace, 0.5f+_baseSpace, 0.5f, self.frameHeight-0.5f-(_baseSpace*2))];
    [_leftLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    _leftLine.alpha = 0.6f;
    
    // 右侧边线样式
    [_rightLine setFrame:CGRectMake(self.frameWidth-0.5f-_baseSpace, _baseSpace, 0.5f, self.frameHeight-0.5f-(_baseSpace*2))];
    [_rightLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    _rightLine.alpha = 0.6f;
    
    // 底部边线样式
    [_bottomLine setFrame:CGRectMake(0.5f+_baseSpace, self.frameHeight-0.5f-_baseSpace, self.frameWidth-0.5f-(_baseSpace*2), 0.5f)];
    [_bottomLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    _bottomLine.alpha = 0.6f;
    
    [_editBtn setFrame:CGRectMake(self.frameWidth - (_editBtnWH+_baseSpace), _baseSpace, _editBtnWH, _editBtnWH)];
    [_editBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];// 设置按钮图片大小
    if(self.editBtnStyle == AppCellEditBtnStyleDelete){
        [_editBtn setImage:[UIImage imageNamed:@"app_common_remove"] forState:UIControlStateNormal];
        [_editBtn setTag:0];
    }
    if(self.editBtnStyle == AppCellEditBtnStyleAdd){
        [_editBtn setImage:[UIImage imageNamed:@"app_common_add"] forState:UIControlStateNormal];
        [_editBtn setTag:1];
    }
    if(self.editBtnStyle == AppCellEditBtnStyleSelected){
        [_editBtn setImage:[UIImage imageNamed:@"app_common_selected"] forState:UIControlStateNormal];
        [_editBtn setTag:2];
    }
    
    // 新角标
    [_newsImageView setFrame:CGRectMake(_baseSpace, _baseSpace, _newImageWH, _newImageWH)];
    
    // 如果image存在，进行设置图片的样式
    if(self.item.webImg || self.item.localImg){
        [_imageView setFrame:CGRectMake(self.frameWidth*0.5f-_imgWH*0.5f, self.frameHeight*0.5f-_imgWH*0.7f, _imgWH, _imgWH)];
        [_imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    // 如果title存在，进行设置标签的样式
    if(self.item.title){
        [_titleLabel setFrame:CGRectMake(0, self.frameHeight*0.7f, self.frameWidth-0.5f, _titleH)];
        [_titleLabel setFont:_titleFont];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor lightGrayColor]];
    }
    
}

#pragma mark - 编辑按钮点击方法
- (void)editBtnClick:(UIButton *)sender {
    // 如果协议响应了appEditViewCellEditBtnClick:方法
    if([_delegate respondsToSelector:@selector(appEditViewCellEditBtnClick:)]){
        [_delegate appEditViewCellEditBtnClick:sender]; // 通知执行协议方法
    }
}

#pragma mark - 重写item的Setter方法
-(void)setItem:(AppModelItem *)item {
    _item = item;
    // 从远程URL获取图片(默认本地图标)
    [_imageView sd_setImageWithURL:[NSURL URLWithString:item.webImg] placeholderImage:[UIImage imageNamed:item.localImg] options:SDWebImageAllowInvalidSSLCertificates completed:nil];
    _titleLabel.text = self.item.title;
    
    [self layoutSubviews];
}


@end
