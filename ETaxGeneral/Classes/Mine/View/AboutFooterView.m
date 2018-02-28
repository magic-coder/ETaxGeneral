/************************************************************
 Class    : AboutFooterView.m
 Describe : 关于界面底部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AboutFooterView.h"

@interface AboutFooterView () <TTTAttributedLabelDelegate>
@property (nonatomic, assign) NSRange boldRange;
@end

@implementation AboutFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        float techFontSize = 12.0f;
        float taxFontSize = 13.0f;
        float labelHeight = 20.0f;
        if(DEVICE_SCREEN_INCH_IPAD){
            techFontSize = 14.0f;
            taxFontSize = 15.0f;
            labelHeight = 22.0f;
        }
        
        // 逆序从下往上依次添加标签
        // 版权信息
        UILabel *statementLabel = [self initializeLabel];
        statementLabel.text = @"Copyright © 2000-2018 Prient. All rights reserved.";
        [self addSubview:statementLabel];
        [statementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.bottom.equalTo(self).with.offset(-5);
            make.height.mas_equalTo(labelHeight);
        }];
        
        // 技术支持
        TTTAttributedLabel *techLabel = [TTTAttributedLabel new];
        techLabel.font = [UIFont systemFontOfSize:techFontSize];
        techLabel.textColor = [UIColor grayColor];
        techLabel.lineBreakMode = NSLineBreakByWordWrapping;
        techLabel.textAlignment = NSTextAlignmentCenter;
        techLabel.highlightedTextColor = DEFAULT_LIGHT_BLUE_COLOR;// 设置高亮颜色
        techLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;// 检测url
        techLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];// 不显示下划线
        techLabel.delegate = self;
        NSString *text = @"技术支持：蓬天信息系统（北京）有限公司";
        
        [techLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            // 设置可点击文字的范围
            NSRange linkRange = [[mutableAttributedString string] rangeOfString:@"蓬天信息系统（北京）有限公司" options:NSCaseInsensitiveSearch];
            // 设置可点击文字的颜色
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)DEFAULT_BLUE_COLOR range:linkRange];
            
            return mutableAttributedString;
        }];
        
        NSRange urlRange = [text rangeOfString:@"蓬天信息系统（北京）有限公司"];
        [techLabel addLinkToURL:[NSURL URLWithString:@"https://micyo202.github.io"] withRange:urlRange];
        
        [self addSubview:techLabel];
        [techLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.bottom.equalTo(statementLabel.mas_top).with.offset(-10);
            make.height.mas_equalTo(labelHeight);
        }];
        
        // 单位机构
        UILabel *taxLabel = [self initializeLabel];
        taxLabel.font = [UIFont boldSystemFontOfSize:taxFontSize];
        taxLabel.text = @"西安市地方税务局";
        [self addSubview:taxLabel];
        [taxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.bottom.equalTo(techLabel.mas_top).with.offset(-5);
            make.height.mas_equalTo(labelHeight);
        }];
        
    }
    return self;
}

#pragma mark - TTTAttributedLabelDelegate 代理方法，url 点击事件
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - 创建基本通用样式的Label
- (UILabel *)initializeLabel{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    //label.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    if(DEVICE_SCREEN_INCH_IPAD){
        label.font = [UIFont systemFontOfSize:14.0f];
    }else{
        label.font = [UIFont systemFontOfSize:12.0f];
    }
    
    //字体自适应
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

@end
