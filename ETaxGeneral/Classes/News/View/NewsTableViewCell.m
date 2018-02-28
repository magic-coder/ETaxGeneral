/************************************************************
 Class    : NewsTableViewCell.m
 Describe : 首页新闻展示自定义TableViewCell样式
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "NewsTableViewCell.h"
#import "NewsModel.h"

//#define TITLE_FONT [UIFont systemFontOfSize:18.0f]
//#define DESCRIBE_FONT [UIFont systemFontOfSize:12.0f]

@interface NewsTableViewCell ()

@property (nonatomic, assign) float baseSpace;

@property (nonatomic, assign) float imageWidth;
@property (nonatomic, assign) float imageHeight;

@property (nonatomic, assign) float fewTitleWidth;
@property (nonatomic, assign) float titleWidth;

@property (nonatomic, assign) float describeWidth;
@property (nonatomic, assign) float describeHeight;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *describeFont;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *oneImageView;

@property (nonatomic, strong) UIImageView *fewImageView;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UILabel *describeLabel;

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation NewsTableViewCell

#pragma mark - 初始化方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _baseSpace = 10;
        
        if(DEVICE_SCREEN_INCH_IPAD){
            _titleFont = [UIFont systemFontOfSize:24.0f];
            _describeFont = [UIFont systemFontOfSize:16.0f];
            
            _describeWidth = 160.0f;// 底部描述标签的宽度
            _describeHeight = 16.0f;// 底部描述标签的高度
        }else{
            _titleFont = [UIFont systemFontOfSize:18.0f];
            _describeFont = [UIFont systemFontOfSize:12.0f];
            
            _describeWidth = 120.0f;// 底部描述标签的宽度
            _describeHeight = 10.0f;// 底部描述标签的高度
        }
        
        _imageWidth = floorf((CGFloat)(WIDTH_SCREEN - _baseSpace * 3)/3);
        _imageHeight = ceilf(_imageWidth*0.65f);// 图片的高度
        
        _titleWidth = WIDTH_SCREEN - (_baseSpace*2);
        _fewTitleWidth = WIDTH_SCREEN - _imageWidth - (_baseSpace*3);
        
        // 添加首页税闻所需全部组件
        _titleLabel = [UILabel new];
        [_titleLabel setFont:_titleFont];
        _titleLabel.numberOfLines = 0;  // 标签显示不限制行数
        [self addSubview:_titleLabel];
        _oneImageView = [UIImageView new];
        [self addSubview:_oneImageView];
        _fewImageView = [UIImageView new];
        [self addSubview:_fewImageView];
        _leftImageView = [UIImageView new];
        [self addSubview:_leftImageView];
        _centerImageView = [UIImageView new];
        [self addSubview:_centerImageView];
        _rightImageView = [UIImageView new];
        [self addSubview:_rightImageView];
        _describeLabel = [UILabel new];
        [_describeLabel setTextColor:[UIColor lightGrayColor]];
        [_describeLabel setFont:_describeFont];
        [self addSubview:_describeLabel];
        _bottomLine = [UIView new];
        [_bottomLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
        //[_bottomLine setAlpha:0.4];
        [self addSubview:_bottomLine];
    }
    
    return self;
}

#pragma mark 布局加载
- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 纯文本样式（没有图片）
    if(_model.style == NewsModelStyleText){
        /*
         float titleLabelX = _baseSpace;
         float titleLabelY = _baseSpace;
         CGSize titleSize = [[BaseHandleUtil sharedBaseHandleUtil] sizeWithString:_model.title font:_titleFont maxSize:CGSizeMake(_titleWidth, MAXFLOAT)];
         float titleLabelW = titleSize.width;
         float titleLabelH = titleSize.height;
         */
        float titleLabelX = _baseSpace;
        float titleLabelY = _baseSpace;
        float titleLabelW = _titleWidth;
        float titleLabelH = [[BaseHandleUtil sharedBaseHandleUtil] calculateHeightWithText:_model.title width:titleLabelW font:_titleFont];
        [_titleLabel setFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
        
        float describeLabelX = _baseSpace;
        float describeLabelY = _titleLabel.frameBottom + _baseSpace;
        float describeLabelW = _describeWidth;
        float describeLabelH = _describeHeight;
        [_describeLabel setFrame:CGRectMake(describeLabelX, describeLabelY, describeLabelW, describeLabelH)];
        
        // 计算cell高度
        _model.cellHeight = _describeLabel.frameBottom + _baseSpace;
    }
    
    // 一张图模式（中间显示一张大图）
    /*
    if(_model.style == NewsModelStyleOneImage){
        float titleLabelX = _baseSpace;
        float titleLabelY = _baseSpace;
        CGSize titleSize = [[BaseHandleUtil sharedBaseHandleUtil] sizeWithString:_model.title font:_titleFont maxSize:CGSizeMake(self.frameWidth - (_baseSpace * 2), MAXFLOAT)];
        float titleLabelW = titleSize.width;
        float titleLabelH = titleSize.height;
        [_titleLabel setFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
        
        float oneImageViewX = _baseSpace;
        float oneImageViewY = _titleLabel.frameBottom + _baseSpace;
        float oneImageViewW = titleLabelW;
        float oneImageViewH = 180;
        [_oneImageView setFrame:CGRectMake(oneImageViewX, oneImageViewY, oneImageViewW, oneImageViewH)];
        
        float describeLabelX = _baseSpace;
        float describeLabelY = _oneImageView.frameBottom + _baseSpace;
        float describeLabelW = describeWidth;
        float describeLabelH = describeHeight;
        [_describeLabel setFrame:CGRectMake(describeLabelX, describeLabelY, describeLabelW, describeLabelH)];
        
        // 计算cell高度
        _model.cellHeight = _describeLabel.frameBottom + _baseSpace;
    }
    */
    
    // 少量图样式（右侧显示一张小图）
    if(_model.style == NewsModelStyleFewImage){
        float fewImageViewW = _imageWidth;
        float fewImageViewH = _imageHeight;
        float fewImageViewX = self.frameWidth - _baseSpace - fewImageViewW;
        float fewImageViewY = _baseSpace;
        [_fewImageView setFrame:CGRectMake(fewImageViewX, fewImageViewY, fewImageViewW, fewImageViewH)];
        
        float titleLabelX = _baseSpace;
        float titleLabelY = _baseSpace;
        CGFloat titleLabelW = _fewTitleWidth;
        CGFloat titleLabelH = [[BaseHandleUtil sharedBaseHandleUtil] calculateHeightWithText:_model.title width:titleLabelW font:_titleFont];
        [_titleLabel setFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
        
        float describeLabelX = _baseSpace;
        float describeLabelY = 0;
        if(titleLabelH + _baseSpace + 8 <= _imageHeight){
            describeLabelY = _baseSpace + _imageHeight - 8;
        }else{
            describeLabelY = _titleLabel.frameBottom + _baseSpace;
        }
        
        float describeLabelW = _describeWidth;
        float describeLabelH = _describeHeight;
        [_describeLabel setFrame:CGRectMake(describeLabelX, describeLabelY, describeLabelW, describeLabelH)];
        
        // 计算cell高度
        if(_describeLabel.frameBottom > _imageHeight){
            _model.cellHeight = _describeLabel.frameBottom + _baseSpace;
        }else{
            _model.cellHeight = _fewImageView.frameBottom + _baseSpace;
        }
    }
    
    // 多图样式（显示三张图）
    if(_model.style == NewsModelStyleMoreImage){
        float titleLabelX = _baseSpace;
        float titleLabelY = _baseSpace;
        float titleLabelW = _titleWidth;
        float titleLabelH = [[BaseHandleUtil sharedBaseHandleUtil] calculateHeightWithText:_model.title width:titleLabelW font:_titleFont];
        [_titleLabel setFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
        
        float leftImageViewX = _baseSpace;
        float leftImageViewY = _titleLabel.frameBottom + _baseSpace;
        float leftImageViewW = _imageWidth;
        float leftImageViewH = _imageHeight;
        [_leftImageView setFrame:CGRectMake(leftImageViewX, leftImageViewY, leftImageViewW, leftImageViewH)];
        
        float centerImageViewX = _leftImageView.frameRight + 5;
        float centerImageViewY = _titleLabel.frameBottom + _baseSpace;
        float centerImageViewW = _imageWidth;
        float centerImageViewH = _imageHeight;
        [_centerImageView setFrame:CGRectMake(centerImageViewX, centerImageViewY, centerImageViewW, centerImageViewH)];
        
        float rightImageViewX = _centerImageView.frameRight + 5;
        float rightImageViewY = _titleLabel.frameBottom + _baseSpace;
        float rightImageViewW = _imageWidth;
        float rightImageViewH = _imageHeight;
        [_rightImageView setFrame:CGRectMake(rightImageViewX, rightImageViewY, rightImageViewW, rightImageViewH)];
        
        float describeLabelX = _baseSpace;
        float describeLabelY = _leftImageView.frameBottom + _baseSpace;
        float describeLabelW = _describeWidth;
        float describeLabelH = _describeHeight;
        [_describeLabel setFrame:CGRectMake(describeLabelX, describeLabelY, describeLabelW, describeLabelH)];
        
        // 计算cell高度
        _model.cellHeight = _describeLabel.frameBottom + _baseSpace;
    }
    
    // 设置每个cell底部线条
    float bottomLineX = _baseSpace;
    float bottomLineY = _model.cellHeight - 0.5f;
    float bottomLineW = self.frameWidth - (_baseSpace * 2);
    float bottomLineH = 0.5f;
    [_bottomLine setFrame:CGRectMake(bottomLineX, bottomLineY, bottomLineW, bottomLineH)];
    
}

#pragma mark 通过Setter方法为模型赋值
- (void)setModel:(NewsModel *)model{
    _model = model;
    
    [_titleLabel setText:_model.title];
    
    switch (_model.style) {
        case NewsModelStyleText: {
            _oneImageView.hidden = YES;
            _fewImageView.hidden = YES;
            _leftImageView.hidden = YES;
            _centerImageView.hidden = YES;
            _rightImageView.hidden = YES;
            break;
        }
        case NewsModelStyleOneImage: {
            NSString *oneImageName = [_model.images objectAtIndex:0];
            oneImageName = [oneImageName stringByReplacingOccurrencesOfString:@"photonews:" withString:@"photonews/"];
            // 获取本地图片
            //_oneImageView.image = [UIImage imageNamed:oneImageName];
            // 从远程url获取https图片
            //[_oneImageView sd_setImageWithURL:[NSURL URLWithString:oneImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates];
            // 从远程url获取图片并裁剪
            [_oneImageView sd_setImageWithURL:[NSURL URLWithString:oneImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                // 在回调block中进行图片裁剪处理（去除一圈白边）
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(20, 20, image.size.width-40, image.size.height-40));
                _fewImageView.image =[UIImage imageWithCGImage:imageRef];
            }];
            
            _oneImageView.hidden = NO;
            _fewImageView.hidden = YES;
            _leftImageView.hidden = YES;
            _centerImageView.hidden = YES;
            _rightImageView.hidden = YES;
            break;
        }
        case NewsModelStyleFewImage: {
            NSString *fewImageName = [_model.images objectAtIndex:0];
            // 获取本地图片
            //[_fewImageView setImage:[UIImage imageNamed:fewImageName]];
            // 从远程url获取https图片
            // [_fewImageView sd_setImageWithURL:[NSURL URLWithString:fewImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:nil];
            // 从远程url获取图片并裁剪
             [_fewImageView sd_setImageWithURL:[NSURL URLWithString:fewImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                 // 在回调block中进行图片裁剪处理（去除一圈白边）
                 CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(20, 20, image.size.width-40, image.size.height-40));
                 _fewImageView.image =[UIImage imageWithCGImage:imageRef];
             }];
            
            _oneImageView.hidden = YES;
            _fewImageView.hidden = NO;
            _leftImageView.hidden = YES;
            _centerImageView.hidden = YES;
            _rightImageView.hidden = YES;
            break;
        }
        default: {
            // NewsModelStyleMoreImage
            NSString *leftImageName = [_model.images objectAtIndex:0];
            NSString *centerImageName = [_model.images objectAtIndex:1];
            NSString *rightImageName = [_model.images objectAtIndex:2];
            // 获取本地图片
            /*
            [_leftImageView setImage:[UIImage imageNamed:leftImageName]];
            [_centerImageView setImage:[UIImage imageNamed:centerImageName]];
            [_rightImageView setImage:[UIImage imageNamed:rightImageName]];
             */
            // 从远程url获取https图片
            /*
             [_leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:nil];
             [_centerImageView sd_setImageWithURL:[NSURL URLWithString:centerImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:nil];
             [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:nil];
             */
            // 从远程url获取图片并裁剪
             [_leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             // 在回调block中进行图片裁剪处理（去除一圈白边）
             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(20, 20, image.size.width-40, image.size.height-40));
             _leftImageView.image =[UIImage imageWithCGImage:imageRef];
             }];
             [_centerImageView sd_setImageWithURL:[NSURL URLWithString:centerImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             // 在回调block中进行图片裁剪处理（去除一圈白边）
             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(20, 20, image.size.width-40, image.size.height-40));
             _centerImageView.image =[UIImage imageWithCGImage:imageRef];
             }];
             [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageName] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             // 在回调block中进行图片裁剪处理（去除一圈白边）
             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(20, 20, image.size.width-40, image.size.height-40));
             _rightImageView.image =[UIImage imageWithCGImage:imageRef];
             }];
            _oneImageView.hidden = YES;
            _fewImageView.hidden = YES;
            _leftImageView.hidden = NO;
            _centerImageView.hidden = NO;
            _rightImageView.hidden = NO;
            break;
        }
    }
    
    // 设置底部显示为来源+时间
    [_describeLabel setText:[NSString stringWithFormat:@"%@  %@",_model.source, _model.datetime]];
    [_describeLabel setText:_model.datetime];
    
    [self layoutSubviews];
}

@end
