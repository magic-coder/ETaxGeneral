/************************************************************
 Class    : AppTopView.m
 Describe : 自定义应用界面顶部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppTopView.h"
#import "YZButton.h"

@interface AppTopView ()

@property (nonatomic, assign) float baseSpace;                  // 通用间隙
@property (nonatomic, assign) float btnHeight;                  // 业务按钮高度
@property (nonatomic, strong) UIFont *btnFont;                  // 操作按钮字体

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation AppTopView

-  (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = DEFAULT_BLUE_COLOR;
        
        _baseSpace = 10.0f;
        _btnHeight = 80.0f;
        _btnFont = [UIFont systemFontOfSize:14.0f];
        
        // 设置视图阴影效果（父类调用时，需要将视图层级关系调整到前面）
        self.layer.shadowOpacity = 0.5;// 设置阴影的透明度 0~1.0
        self.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
        self.layer.shadowOffset = CGSizeMake(0, 3);// 阴影的位移
        self.layer.shadowRadius = 10;// 阴影的模糊程度
        
        [self addSubview:self.backgroundImageView];
        [self addSearchBar];
        [self addHandleButton];
    }
    return self;
}

#pragma mark - 背景图片视图懒加载Getter方法
- (UIImageView *)backgroundImageView {
    if(!_backgroundImageView){
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        // [UIImage imageWithColor:DEFAULT_BLUE_COLOR]
        [_backgroundImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"app_top_bg"] options:SDWebImageAllowInvalidSSLCertificates completed:nil];
        _backgroundImageView.userInteractionEnabled = YES;
        _backgroundImageView.multipleTouchEnabled = YES;
        // 控制子视图不能超出父视图的范围
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

#pragma mark - 添加搜索栏
- (void)addSearchBar {
    // 添加搜索框
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, HEIGHT_STATUS+10, self.frameWidth - 60 - 15, 26)];
    searchTextField.layer.cornerRadius = 5;
    searchTextField.layer.borderWidth = .5;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.layer.borderColor = DEFAULT_BACKGROUND_COLOR.CGColor;
    searchTextField.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    searchTextField.alpha = 0.3f;
    [self.backgroundImageView addSubview:searchTextField];
    
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(searchTextField.originX+4, searchTextField.originY+1, 24, 24)];
    imgSearch.image = [UIImage imageNamed:@"app_common_searchHL"];
    [self.backgroundImageView addSubview:imgSearch];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchTextField.originX+26+10, searchTextField.originY, 120, 26)];
    searchLabel.textColor = [UIColor whiteColor];
    searchLabel.font = [UIFont systemFontOfSize:14.0f];
    searchLabel.text = @"应用搜索";
    [self.backgroundImageView addSubview:searchLabel];
    
    UIButton *btn_search_frame = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_search_frame.frame = searchTextField.frame;
    btn_search_frame.tag = 1;
    [btn_search_frame addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundImageView addSubview:btn_search_frame];   // 搜索按钮
}

#pragma mark - 添加应用操作按钮
- (void)addHandleButton {
    UIButton *btn_edit = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_edit.frame = CGRectMake(self.frameWidth-50, HEIGHT_STATUS+2, 46, 46);
    [btn_edit setImage:[UIImage imageNamed:@"app_common_edit"] forState:UIControlStateNormal];
    [btn_edit setImage:[UIImage imageNamed:@"app_common_editHL"] forState:UIControlStateHighlighted];
    btn_edit.tag = 2;
    
    CGFloat btnW = floorf((CGFloat)(self.frameWidth - (_baseSpace * 5))/4);
    
    // 老方法iPad错乱问题，废除该方法
    /*
    UIButton *btn_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_1.frame = CGRectMake(_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_1 setImage:[UIImage imageNamed:@"app_top_notification"] forState:UIControlStateNormal];
    [btn_1 setImage:[UIImage imageNamed:@"app_top_notificationHL"] forState:UIControlStateHighlighted];
    [btn_1 setTitle:@"通知公告" forState:UIControlStateNormal];
    [btn_1.titleLabel setFont:_btnFont];
    btn_1.tag = 21;
    [btn_1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_1 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    btn_1.imageEdgeInsets = UIEdgeInsetsMake(- (btn_1.frameHeight - btn_1.titleLabel.frameHeight- btn_1.titleLabel.originY),(self.frameWidth - (_baseSpace*5))/4/2 - btn_1.imageView.frameWidth/2, 0, 0);
    btn_1.titleEdgeInsets = UIEdgeInsetsMake(btn_1.frameHeight-btn_1.imageView.frameHeight-btn_1.imageView.originY+_baseSpace, -btn_1.imageView.frameWidth*0.9f, 0, 0);
    
    UIButton *btn_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_2.frame = CGRectMake(btn_1.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_2 setImage:[UIImage imageNamed:@"app_top_contacts"] forState:UIControlStateNormal];
    [btn_2 setImage:[UIImage imageNamed:@"app_top_contactsHL"] forState:UIControlStateHighlighted];
    [btn_2 setTitle:@"局通讯录" forState:UIControlStateNormal];
    [btn_2.titleLabel setFont:_btnFont];
    btn_2.tag = 22;
    [btn_2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_2 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    btn_2.imageEdgeInsets = UIEdgeInsetsMake(- (btn_2.frameHeight - btn_2.titleLabel.frameHeight- btn_2.titleLabel.originY),(self.frameWidth - 50)/4/2 - btn_2.imageView.frameWidth/2, 0, 0);
    btn_2.titleEdgeInsets = UIEdgeInsetsMake(btn_2.frameHeight-btn_2.imageView.frameHeight-btn_2.imageView.originY+_baseSpace, -btn_2.imageView.frameWidth*0.9f, 0, 0);
    
    UIButton *btn_3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_3.frame = CGRectMake(btn_2.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_3 setImage:[UIImage imageNamed:@"app_top_map"] forState:UIControlStateNormal];
    [btn_3 setImage:[UIImage imageNamed:@"app_top_mapHL"] forState:UIControlStateHighlighted];
    [btn_3 setTitle:@"税务地图" forState:UIControlStateNormal];
    [btn_3.titleLabel setFont:_btnFont];
    btn_3.tag = 23;
    [btn_3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_3 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    btn_3.imageEdgeInsets = UIEdgeInsetsMake(- (btn_3.frameHeight - btn_3.titleLabel.frameHeight- btn_3.titleLabel.originY),(self.frameWidth - 50)/4/2 - btn_3.imageView.frameWidth/2, 0, 0);
    btn_3.titleEdgeInsets = UIEdgeInsetsMake(btn_3.frameHeight-btn_3.imageView.frameHeight-btn_3.imageView.originY+_baseSpace, -btn_3.imageView.frameWidth*0.9f, 0, 0);
    btn_3.backgroundColor = [UIColor redColor];
    
    UIButton *btn_4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_4.frame = CGRectMake(btn_3.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_4 setImage:[UIImage imageNamed:@"app_top_question"] forState:UIControlStateNormal];
    [btn_4 setImage:[UIImage imageNamed:@"app_top_questionHL"] forState:UIControlStateHighlighted];
    [btn_4 setTitle:@"常见问题" forState:UIControlStateNormal];
    [btn_4.titleLabel setFont:_btnFont];
    btn_4.tag = 24;
    [btn_4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_4 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    btn_4.imageEdgeInsets = UIEdgeInsetsMake(- (btn_4.frameHeight - btn_4.titleLabel.frameHeight- btn_4.titleLabel.originY),(self.frameWidth - 50)/4/2 - btn_4.imageView.frameWidth/2, 0, 0);
    btn_4.titleEdgeInsets = UIEdgeInsetsMake(btn_4.frameHeight-btn_4.imageView.frameHeight-btn_4.imageView.originY+_baseSpace, -btn_4.imageView.frameWidth*0.9f, 0, 0);
    */
    
    // 采用最新方法YZButton来进行生成自定义布局的按钮
    YZButton *btn_1 = [YZButton buttonWithType:UIButtonTypeCustom];
    btn_1.frame = CGRectMake(_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_1 setImage:[UIImage imageNamed:@"app_top_notification"] forState:UIControlStateNormal];
    [btn_1 setImage:[UIImage imageNamed:@"app_top_notificationHL"] forState:UIControlStateHighlighted];
    [btn_1 setTitle:@"通知公告" forState:UIControlStateNormal];
    btn_1.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn_1.titleLabel setFont:_btnFont];
    btn_1.tag = 21;
    btn_1.imageRect = CGRectMake(btnW/2-20, 5, 40, 40);
    btn_1.titleRect = CGRectMake(5, _btnHeight-25, btnW-10, 20);
    [btn_1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_1 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    
    YZButton *btn_2 = [YZButton buttonWithType:UIButtonTypeCustom];
    btn_2.frame = CGRectMake(btn_1.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_2 setImage:[UIImage imageNamed:@"app_top_contacts"] forState:UIControlStateNormal];
    [btn_2 setImage:[UIImage imageNamed:@"app_top_contactsHL"] forState:UIControlStateHighlighted];
    [btn_2 setTitle:@"通讯录" forState:UIControlStateNormal];
    btn_2.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn_2.titleLabel setFont:_btnFont];
    btn_2.tag = 22;
    btn_2.imageRect = CGRectMake(btnW/2-20, 5, 40, 40);
    btn_2.titleRect = CGRectMake(5, _btnHeight-25, btnW-10, 20);
    [btn_2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_2 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    
    YZButton *btn_3 = [YZButton buttonWithType:UIButtonTypeCustom];
    btn_3.frame = CGRectMake(btn_2.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_3 setImage:[UIImage imageNamed:@"app_top_map"] forState:UIControlStateNormal];
    [btn_3 setImage:[UIImage imageNamed:@"app_top_mapHL"] forState:UIControlStateHighlighted];
    [btn_3 setTitle:@"税务地图" forState:UIControlStateNormal];
    btn_3.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn_3.titleLabel setFont:_btnFont];
    btn_3.tag = 23;
    btn_3.imageRect = CGRectMake(btnW/2-20, 5, 40, 40);
    btn_3.titleRect = CGRectMake(5, _btnHeight-25, btnW-10, 20);
    [btn_3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_3 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    
    YZButton *btn_4 = [YZButton buttonWithType:UIButtonTypeCustom];
    btn_4.frame = CGRectMake(btn_3.frameRight+_baseSpace, self.frameHeight-_btnHeight-(_baseSpace/2), btnW, _btnHeight);
    [btn_4 setImage:[UIImage imageNamed:@"app_top_question"] forState:UIControlStateNormal];
    [btn_4 setImage:[UIImage imageNamed:@"app_top_questionHL"] forState:UIControlStateHighlighted];
    [btn_4 setTitle:@"常见问题" forState:UIControlStateNormal];
    btn_4.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn_4.titleLabel setFont:_btnFont];
    btn_4.tag = 24;
    btn_4.imageRect = CGRectMake(btnW/2-20, 5, 40, 40);
    btn_4.titleRect = CGRectMake(5, _btnHeight-25, btnW-10, 20);
    [btn_4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_4 setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    
    // 注册按钮点击事件
    [btn_edit addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn_1 addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn_2 addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn_3 addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn_4 addTarget:self action:@selector(appBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backgroundImageView addSubview:btn_edit];     // 右侧编辑按钮
    [self.backgroundImageView addSubview:btn_1];
    [self.backgroundImageView addSubview:btn_2];
    [self.backgroundImageView addSubview:btn_3];
    [self.backgroundImageView addSubview:btn_4];
    
}

#pragma mark - 按钮点击代理方法
- (void)appBtnOnClick:(UIButton *)sender{
    // 如果协议响应了appTopViewBtnClick方法
    if([_delegate respondsToSelector:@selector(appTopViewBtnClick:)]){
        [_delegate appTopViewBtnClick:sender]; // 通知执行协议方法
    }
}

@end
