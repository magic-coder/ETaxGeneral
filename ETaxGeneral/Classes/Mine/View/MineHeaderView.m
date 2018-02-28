/************************************************************
 Class    : MineHeaderView.m
 Describe : 我的界面顶部头视图展示基本信息
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MineHeaderView.h"

@interface MineHeaderView ()

@property (nonatomic, assign) float bottomH;

@end

@implementation MineHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        // 初始化底部通用菜单视图高度
        if(DEVICE_SCREEN_INCH_IPAD){
            _bottomH = floorf(self.frameHeight*0.2f);
        }else{
            _bottomH = 70.0f;
        }
        
        // 初始化主视图（用户头像、姓名、部门等...）
        [self initializeMainView];
        // 初始化底部视图
        [self initializeBottomView];
        
    }
    return self;
}

#pragma mark - 初始化主视图样式
- (void)initializeMainView{
    
    _imageView = [UIImageView new];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"mine_account_bg"] options:SDWebImageAllowInvalidSSLCertificates completed:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, _bottomH, 0));
    }];
    
    CGSize nightShiftSize = CGSizeMake(20, 20);
    
    _nightShiftBtn = [UIButton new];
    NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    if([[settingDict objectForKey:@"nightShift"] boolValue]){
        [_nightShiftBtn setBackgroundImage:[UIImage imageNamed:@"mine_account_sun"] forState:UIControlStateNormal];
        [_nightShiftBtn setBackgroundImage:[UIImage imageNamed:@"mine_account_sunHL"] forState:UIControlStateHighlighted];
    }else{
        [_nightShiftBtn setBackgroundImage:[UIImage imageNamed:@"mine_account_moon"] forState:UIControlStateNormal];
        [_nightShiftBtn setBackgroundImage:[UIImage imageNamed:@"mine_account_moonHL"] forState:UIControlStateHighlighted];
    }
    [_nightShiftBtn addTarget:self action:@selector(nightShiftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nightShiftBtn];
    [_nightShiftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(HEIGHT_STATUS+10);
        make.right.equalTo(self).with.offset(-15);
        make.size.mas_equalTo(nightShiftSize);
    }];
    
    CGSize accountImageSize = CGSizeMake(70, 70);
    
    _accountImageView = [UIImageView new];
    [self addSubview:_accountImageView];
    [_accountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).with.offset(-10);
        make.left.equalTo(self).with.offset(ceilf(WIDTH_SCREEN*0.125f));
        make.size.mas_equalTo(accountImageSize);
    }];
    
    _accountBtn = [UIButton new];
    [_accountBtn addTarget:self action:@selector(btnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    _accountBtn.tag = 0;
    [self addSubview:_accountBtn];
    [_accountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_accountImageView);
        make.right.equalTo(self).with.mas_offset(-ceilf(WIDTH_SCREEN*0.125f));
        make.height.equalTo(_accountImageView);
    }];
    
    CGSize levelSize = CGSizeMake(32, 12);
    
    _levelLabel = [self initializeHeaderLabel];
    _levelLabel.backgroundColor = RgbColor(240, 180, 0, 1.f);
    _levelLabel.font = [UIFont systemFontOfSize:13.0f];
    _levelLabel.text = @"Lv 0";
    _levelLabel.layer.masksToBounds = YES;
    _levelLabel.layer.cornerRadius = 6;
    [self addSubview:_levelLabel];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_accountImageView.mas_right).with.offset(-20);
        make.bottom.equalTo(_accountBtn);
        make.size.mas_equalTo(levelSize);
    }];
    
    float nameFontSize = 26.0f;
    float nameHeight = 30.0f;
    
    _nameLabel = [self initializeHeaderLabel];
    _nameLabel.font = [UIFont boldSystemFontOfSize:nameFontSize];
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_accountImageView).with.offset(15);
        make.left.mas_equalTo(ceilf(WIDTH_SCREEN*0.32f));
        make.width.mas_equalTo(WIDTH_SCREEN-ceilf(WIDTH_SCREEN*0.32f));
        make.height.mas_equalTo(nameHeight);
    }];
    
    float orgNnameFontSize = 14.0f;
    float orgNameHeight = 20.0f;
    
    _orgNameLabel = [self initializeHeaderLabel];
    _orgNameLabel.font = [UIFont systemFontOfSize:orgNnameFontSize];
    [self addSubview:_orgNameLabel];
    [_orgNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).offset(5);
        make.left.equalTo(_nameLabel);
        make.width.equalTo(_nameLabel);
        make.height.mas_equalTo(orgNameHeight);
    }];
}

#pragma mark - 初始化底部视图样式（3个操作性按钮）
- (void)initializeBottomView{
    
    _bottomView = [UIView new];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.equalTo(self);
        make.height.mas_equalTo(_bottomH);
    }];
    
    _topLineView = [UIView new];
    _topLineView.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    [_bottomView addSubview:_topLineView];
    [_topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(_bottomView);
        make.height.mas_equalTo(0.5f);
    }];
    
    CGFloat btnW = floorf((CGFloat)self.frameWidth/3)-20.0f;
    CGFloat btnH = _bottomH-10.0f;
    
    _leftBtn = [YZButton buttonWithType:UIButtonTypeCustom];
    [_leftBtn setImage:[UIImage imageNamed:@"mine_rule"] forState:UIControlStateNormal];
    [_leftBtn setImage:[UIImage imageNamed:@"mine_rule"] forState:UIControlStateHighlighted];
    [_leftBtn setTitle:@"升级规则" forState:UIControlStateNormal];
    _leftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_leftBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    _leftBtn.imageRect = CGRectMake(btnW/2-16, 0, 32, 32);
    _leftBtn.titleRect = CGRectMake(0, btnH-16, btnW, 16);
    [_leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_leftBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_leftBtn addTarget:self action:@selector(btnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    _leftBtn.tag = 1;
    [_bottomView addSubview:_leftBtn];
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-floorf((CGFloat)self.frameWidth/3));
        make.centerY.equalTo(_bottomView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    
    _firstLineView = [UIView new];
    _firstLineView.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    [_bottomView addSubview:_firstLineView];
    [_firstLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomView).with.offset(-floorf((CGFloat)self.frameWidth/6));
        make.top.equalTo(_bottomView).with.offset(10);
        make.bottom.equalTo(_bottomView).with.offset(-10);
        make.width.mas_equalTo(0.5f);
    }];
    
    _middleBtn = [YZButton buttonWithType:UIButtonTypeCustom];
    [_middleBtn setImage:[UIImage imageNamed:@"mine_level"] forState:UIControlStateNormal];
    [_middleBtn setImage:[UIImage imageNamed:@"mine_level"] forState:UIControlStateHighlighted];
    [_middleBtn setTitle:@"白金用户" forState:UIControlStateNormal];
    _middleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_middleBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    _middleBtn.imageRect = CGRectMake(btnW/2-16, 0, 32, 32);
    _middleBtn.titleRect = CGRectMake(0, btnH-16, btnW, 16);
    [_middleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_middleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_middleBtn addTarget:self action:@selector(btnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    _middleBtn.tag = 2;
    [_bottomView addSubview:_middleBtn];
    [_middleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomView);
        make.centerY.equalTo(_bottomView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    
    _secondLineView = [UIView new];
    _secondLineView.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    [_bottomView addSubview:_secondLineView];
    [_secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomView).with.offset(floorf((CGFloat)self.frameWidth/6));
        make.top.equalTo(_bottomView).with.offset(10);
        make.bottom.equalTo(_bottomView).with.offset(-10);
        make.width.mas_equalTo(0.5f);
    }];
    
    _rightBtn = [YZButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setImage:[UIImage imageNamed:@"mine_sign"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"mine_sign"] forState:UIControlStateHighlighted];
    [_rightBtn setTitle:@"每日签到" forState:UIControlStateNormal];
    _rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_rightBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    _rightBtn.imageRect = CGRectMake(btnW/2-16, 0, 32, 32);
    _rightBtn.titleRect = CGRectMake(0, btnH-16, btnW, 16);
    [_rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_rightBtn addTarget:self action:@selector(btnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn.tag = 3;
    [_bottomView addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(floorf((CGFloat)self.frameWidth/3));
        make.centerY.equalTo(_bottomView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    
    // 生成底部横线
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    [_bottomView addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_bottomView);
        make.height.mas_equalTo(0.5f);
    }];
    
}

#pragma mark - 创建头部通用样式的Label
- (UILabel *)initializeHeaderLabel{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    //label.font = [UIFont boldSystemFontOfSize:16.0f];
    //label.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    //字体自适应
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

#pragma mark - 夜间护眼模式按钮点击方法
- (void)nightShiftAction:(UIButton *)sender{
    NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    if(![[settingDict objectForKey:@"nightShift"] boolValue]){
        [sender setBackgroundImage:[UIImage imageNamed:@"mine_account_sun"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"mine_account_sunHL"] forState:UIControlStateHighlighted];
        [[UIScreen mainScreen] setBrightness:0];
        [settingDict setObject:[NSNumber numberWithBool:YES] forKey:@"nightShift"];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"mine_account_moon"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"mine_account_moonHL"] forState:UIControlStateHighlighted];
        [[UIScreen mainScreen] setBrightness:0.5f];
        [settingDict setObject:[NSNumber numberWithBool:NO] forKey:@"nightShift"];
    }
    [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
}

#pragma mark - 按钮点击代理方法
- (void)btnDidSelected:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(mineHeaderViewBtnDidSelected:)]) {
        [self.delegate mineHeaderViewBtnDidSelected:sender];
    }
}

// 重写Setter 方法
- (void)setNameText:(NSString *)nameText{
    _nameLabel.text = nameText;
    if([nameText isEqualToString:@"未登录"]){
        _levelLabel.backgroundColor = [UIColor lightGrayColor];
        _levelLabel.text = @"Lv 0";
        _orgNameLabel.text = @"登录后，即可享用更多功能！";
        
        [_accountImageView setImage:[UIImage imageNamed:@"mine_account_header_grey"]];
    }else{
        _levelLabel.backgroundColor = RgbColor(240, 180, 0, 1.f);
        //_levelLabel.text = [NSString stringWithFormat:@"Lv %@", [[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS] objectForKey:@"level"]];
        _levelLabel.text = @"Lv 0";
        _orgNameLabel.text = [[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS] objectForKey:@"orgName"];
        
        [_accountImageView setImage:[UIImage imageNamed:@"mine_account_header_color"]];
    }
}

@end
