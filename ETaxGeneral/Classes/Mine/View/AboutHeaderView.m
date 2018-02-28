/************************************************************
 Class    : AboutHeaderView.m
 Describe : 关于界面头部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AboutHeaderView.h"

@implementation AboutHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        float imageTop = ceilf(frame.size.height*0.074f);
        CGSize imageSize = CGSizeMake(160.0f, 160.0f);
        if(DEVICE_SCREEN_INCH_IPAD)
            imageSize = CGSizeMake(200.0f, 200.0f);
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"common_barcode"];
        //imageView.image = [UIImage imageNamed:@"about_logo" scaleToSize:imageView.size];
        
        //imageView.layer.masksToBounds = YES;// 隐藏边界
        //imageView.layer.cornerRadius = 12;// 将图层的边框设置为圆角
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).with.offset(imageTop);
            make.size.mas_equalTo(imageSize);
        }];
        
        float nameFontSize = 14.0f;
        float nameHeight = 20.0f;
        if(DEVICE_SCREEN_INCH_IPAD){
            nameFontSize = 16.0f;
            nameHeight = 22.0f;
        }
            
        UILabel *nameLabel = [self initializeLabel];
        nameLabel.font = [UIFont boldSystemFontOfSize:nameFontSize];
        nameLabel.text = [[Variable sharedVariable] appName];
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.top.equalTo(imageView.mas_bottom).with.offset(5);
            make.height.mas_equalTo(nameHeight);
        }];
        
        float versionFontSize = 12.0f;
        float versionHeight = 20.0f;
        if(DEVICE_SCREEN_INCH_IPAD){
            versionFontSize = 14.0f;
            versionHeight = 22.0f;
        }
        
        UILabel *versionLabel = [self initializeLabel];
        versionLabel.text = [NSString stringWithFormat:@"For iPhone V%@ build%@", [[Variable sharedVariable] appVersion], [[Variable sharedVariable] buildVersion]];
        versionLabel.font = [UIFont systemFontOfSize:versionFontSize];
        versionLabel.textColor = [UIColor grayColor];
        [self addSubview:versionLabel];
        [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.top.equalTo(nameLabel.mas_bottom);
            make.height.mas_equalTo(versionHeight);
        }];
        
    }
    return self;
}

#pragma mark - 创建基本通用样式的Label
- (UILabel *)initializeLabel{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    //label.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    //字体自适应
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

@end
