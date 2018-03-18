/************************************************************
 Class    : LoginViewController.m
 Describe : 用户登录视图界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-13
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "LoginViewController.h"
#import "MainTabBarController.h"
#import "OneWayHTTPS.h"
#import "AppDelegate.h"

#define LABELSIZE CGSizeMake(70, 20)
#define TEXTFIELDSIZE CGSizeMake(180, 30)

typedef NS_ENUM(NSInteger, LoginShowType) {
    LoginShowType_NONE,
    LoginShowType_USER,
    LoginShowType_PASS
};
@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) MainTabBarController *mainTabBarController;

@property (nonatomic, assign) LoginShowType showType;

@property (nonatomic, strong) UIVisualEffectView *smallView;

@property (nonatomic, strong) UIImageView* imgLeftHand;
@property (nonatomic, strong) UIImageView* imgRightHand;

@property (nonatomic, strong) UIImageView* imgLeftHandGone;
@property (nonatomic, strong) UIImageView* imgRightHandGone;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *authCodeTextField;

@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIButton *registerBtn;
@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,assign) BOOL isMove;  // 是否移动

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    // 背景
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.image = [UIImage imageNamed:@"login_bg"];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    // 背景模糊（毛玻璃效果）
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectview.frame = CGRectMake(0, 0, _imageView.frameWidth, _imageView.frameHeight);
    [_imageView addSubview:effectview];
    
    // head (人头)
    UIImageView* imgLogin = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frameWidth / 2 - 211 / 2, 150-109, 211, 108)];
    imgLogin.image = [UIImage imageNamed:@"login_head"];
    imgLogin.layer.masksToBounds = YES;
    [self.view addSubview:imgLogin];
    
    // 左手/右手
    _imgLeftHand = [[UIImageView alloc] initWithFrame:CGRectMake(1, 100, 40, 65)];
    _imgLeftHand.image = [UIImage imageNamed:@"login_arm_left"];
    [imgLogin addSubview:_imgLeftHand];
    
    _imgRightHand = [[UIImageView alloc] initWithFrame:CGRectMake(imgLogin.frameWidth / 2 + 60, 90, 40, 65)];
    _imgRightHand.image = [UIImage imageNamed:@"login_arm_right"];
    [imgLogin addSubview:_imgRightHand];
    
    // 展开的左手/右手
    _imgLeftHandGone = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frameWidth / 2 - 100, 150-22, 40, 40)];
    _imgLeftHandGone.image = [UIImage imageNamed:@"login_hand"];
    [self.view addSubview:_imgLeftHandGone];
    
    
    _imgRightHandGone = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frameWidth / 2 + 62,  150-22, 40, 40)];
    _imgRightHandGone.image = [UIImage imageNamed:@"login_hand"];
    [self.view addSubview:_imgRightHandGone];
    
    _smallView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    if(DEVICE_SCREEN_INCH_IPAD){
        _smallView.size = CGSizeMake(self.view.frameWidth/2, self.view.frameWidth/2);
        _smallView.center = CGPointMake(WIDTH_SCREEN/2, 150+_smallView.frameHeight/2);
    }else{
        _smallView.frame = CGRectMake(20, 150, self.view.frameWidth-40, self.view.frameWidth-40);
    }
    _smallView.layer.cornerRadius = 5;
    _smallView.layer.masksToBounds = YES;
    [self.view addSubview:_smallView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, _smallView.frameWidth-20, 20)];
    self.titleLabel.text = @"用户登录";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_smallView.contentView addSubview:self.titleLabel];
    
    self.usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame)+15, _smallView.frameWidth-40, 40)];
    self.usernameTextField.delegate = self;
    self.usernameTextField.layer.cornerRadius = 5;
    self.usernameTextField.layer.borderWidth = .5;
    self.usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.usernameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.usernameTextField.placeholder = @"请输入用户名";
    self.usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.usernameTextField.frame), CGRectGetHeight(self.usernameTextField.frame))];
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgUser = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 22, 22)];
    imgUser.image = [UIImage imageNamed:@"login_username"];
    [self.usernameTextField.leftView addSubview:imgUser];
    self.usernameTextField.keyboardType = UIKeyboardTypeASCIICapable;   // 设置键盘类型
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOGINCODE];// 显示最后一次登录用户名
    [_smallView.contentView addSubview:self.usernameTextField];
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMaxY(self.usernameTextField.frame)+10, CGRectGetWidth(self.usernameTextField.frame), CGRectGetHeight(self.usernameTextField.frame))];
    self.passwordTextField.delegate = self;
    self.passwordTextField.layer.cornerRadius = 5;
    self.passwordTextField.layer.borderWidth = .5;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.passwordTextField.placeholder = @"请输入密码";
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.passwordTextField.frame), CGRectGetHeight(self.passwordTextField.frame))];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
    imgPwd.image = [UIImage imageNamed:@"login_password"];
    [self.passwordTextField.leftView addSubview:imgPwd];
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;   // 设置键盘类型
    [_smallView.contentView addSubview:self.passwordTextField];
    
    
    self.authCodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.passwordTextField.frame)+10, CGRectGetWidth(self.passwordTextField.frame)-120, CGRectGetHeight(self.passwordTextField.frame))];
    self.authCodeTextField.delegate = self;
    self.authCodeTextField.layer.cornerRadius = 5;
    self.authCodeTextField.layer.borderWidth = .5;
    self.authCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.authCodeTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.authCodeTextField.placeholder = @"验证码";
    self.authCodeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.usernameTextField.frame), CGRectGetHeight(self.usernameTextField.frame))];
    self.authCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgAuth = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 22, 22)];
    imgAuth.image = [UIImage imageNamed:@"login_authcode"];
    [self.authCodeTextField.leftView addSubview:imgAuth];
    self.authCodeTextField.keyboardType = UIKeyboardTypeNumberPad;   // 设置键盘类型
    [_smallView.contentView addSubview:self.authCodeTextField];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(_smallView.frameWidth-120, CGRectGetMaxY(self.passwordTextField.frame)+10, 100, 40)];
    [self.sendBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.sendBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(255.0, 170.0, 0.0, 1.0f)] forState:UIControlStateNormal];
    [self.sendBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(255.0, 190.0, 20.0, 1.0f)] forState:UIControlStateHighlighted];
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.layer.cornerRadius = 5;
    [self.sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_smallView.contentView addSubview:self.sendBtn];
    
    self.loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.authCodeTextField.frame)+10, _smallView.frameWidth-40, 40)];
    [self.loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(80.0, 150.0, 230.0, 1.0f)] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(120.0, 180.0, 230.0, 1.0f)] forState:UIControlStateHighlighted];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 5;
    [self.loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [_smallView.contentView addSubview:self.loginBtn];
    
    // 添加注册按钮
    self.registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.loginBtn.frame)+10, _smallView.frameWidth-40, 40)];
    [self.registerBtn setTitle:@"注 册" forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:HexColor(@"#969696", 1.0f) forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(255.0, 255.0, 255.0, 1.0f)] forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:RgbColor(235.0, 235.0, 235.0, 1.0f)] forState:UIControlStateHighlighted];
    self.registerBtn.layer.masksToBounds = YES;
    self.registerBtn.layer.cornerRadius = 5;
    [self.registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_smallView.contentView addSubview:self.registerBtn];
    
    
    // 自定义左上角(返回按钮)
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(5, 5, 45, 45);
    [self.cancelBtn setImage:[UIImage imageNamed:@"login_cancel"] forState:UIControlStateNormal];
    [self.cancelBtn setImage:[UIImage imageNamed:@"login_cancelHL"] forState:UIControlStateHighlighted];
    [self.cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    
    if(DEVICE_SCREEN_INCH_IPAD){
        _smallView.size = CGSizeMake(WIDTH_SCREEN/2, CGRectGetMaxY(self.registerBtn.frame)+15);
        _smallView.center = CGPointMake(WIDTH_SCREEN/2, 150+_smallView.frameHeight/2);
    }else{
        _smallView.frame = CGRectMake(20, 150, self.view.frameWidth-40, CGRectGetMaxY(self.registerBtn.frame)+15);
    }
    
}

#pragma mark - 视图已经展示方法，隐藏顶部状态栏
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}

#pragma mark - 视图已经销毁方法，显示顶部状态栏
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - <UITextFieldDelegate>代理方法
// 敬礼移动动画
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.6f animations:^{
        //_imgLeftHand.frame = CGRectMake(_imgLeftHand.frame.origin.x + 60, _imgLeftHand.frame.origin.y - 30, _imgLeftHand.frame.size.width, _imgLeftHand.frame.size.height);
        _imgLeftHand.frame = CGRectMake(_imgLeftHand.frame.origin.x + 40, _imgLeftHand.frame.origin.y - 55, _imgLeftHand.frame.size.width, _imgLeftHand.frame.size.height);
        
        _imgRightHand.frame = CGRectMake(_imgRightHand.frame.origin.x - 48, _imgRightHand.frame.origin.y - 30, _imgRightHand.frame.size.width, _imgRightHand.frame.size.height);
        
        _imgLeftHandGone.frame = CGRectMake(_imgLeftHandGone.frame.origin.x + 70, _imgLeftHandGone.frame.origin.y, 0, 0);
        
        _imgRightHandGone.frame = CGRectMake(_imgRightHandGone.frame.origin.x - 30, _imgRightHandGone.frame.origin.y, 0, 0);
        
    } completion:^(BOOL b) {
        if(!_isMove){
            CGFloat rects = self.view.frameHeight - (self.smallView.frameHeight + 216 + 149);
            if (rects <= 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = self.view.frame;
                    frame.origin.y = rects;
                    self.view.frame = frame;
                }];
            }
            _isMove = YES;
        }else{
            _isMove = NO;
        }
        
    }];
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.6f animations:^{
        _imgLeftHand.frame = CGRectMake(_imgLeftHand.frame.origin.x - 40, _imgLeftHand.frame.origin.y + 55, _imgLeftHand.frame.size.width, _imgLeftHand.frame.size.height);
        
        _imgRightHand.frame = CGRectMake(_imgRightHand.frame.origin.x + 48, _imgRightHand.frame.origin.y + 30, _imgRightHand.frame.size.width, _imgRightHand.frame.size.height);
        
        _imgLeftHandGone.frame = CGRectMake(_imgLeftHandGone.frame.origin.x - 70, _imgLeftHandGone.frame.origin.y, 40, 40);
        
        _imgRightHandGone.frame = CGRectMake(_imgRightHandGone.frame.origin.x + 30, _imgRightHandGone.frame.origin.y, 40, 40);
        
    } completion:^(BOOL b) {
        if(_isMove){
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.view.frame;
                frame.origin.y = 0.0f;
                self.view.frame = frame;
            }];
            _isMove = NO;
        }else{
            _isMove = YES;
        }
    }];
    
}

#pragma mark - 点击空白处隐藏键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - 发送验证码方法
-(void)sendAction:(UIButton *)sender{
    
    // 防止重复点击（间隔1秒）
    CLICK_LOCK
    
    NSString *userCode = _usernameTextField.text;
    if(userCode.length > 0){
        
        NSDictionary *dict = @{@"userCode": userCode};
        
        NSString *url = [NSString stringWithFormat:@"%@account/getVerificationCode", SERVER_URL];// 格式化请求 URL 参数
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[BaseHandleUtil sharedBaseHandleUtil] JSONStringWithObject:dict], @"msg", nil];   // 格式化参数
        
        [OneWayHTTPS POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            if([@"00" isEqualToString:[responseObject objectForKey:@"statusCode"]]){    // 成功标志
                [MBProgressHUD showHUDView:self.view text:[responseObject objectForKey:@"msg"] progressHUDMode:(YZProgressHUDModeShow)];
                //正常状态下的背景颜色
                UIColor *mainColor = RgbColor(255.0, 170.0, 0.0, 1.0f);
                //倒计时状态下的颜色
                UIColor *countColor = RgbColor(188.0, 188.0, 188.0, 0.9f);
                [self setTheCountdownButton:sender startWithTime:59 title:@"获取验证码" countDownTitle:@"秒后重试" mainColor:mainColor countColor:countColor];
            }else{
                [MBProgressHUD showHUDView:self.view text:[responseObject objectForKey:@"msg"] progressHUDMode:YZProgressHUDModeShow];
            }
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
        }];
        
    }else{
        [MBProgressHUD showHUDView:self.view text:@"请输入用户名，再获取验证码！" progressHUDMode:(YZProgressHUDModeShow)];
    }
}

#pragma mark - 登录方法
-(void)loginAction:(UIButton *)sender{
    
    // 防止重复点击（间隔1秒）
    CLICK_LOCK
    
    NSString *userCode = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *authCode = _authCodeTextField.text;
    
    if(userCode.length > 0 && password.length > 0 && authCode.length > 0){
        
        [MBProgressHUD showHUDView:self.view text:@"登录中..." progressHUDMode:(YZProgressHUDModeLock)];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:userCode forKey:@"userCode"];
        [dict setObject:password forKey:@"password"];
        [dict setObject:authCode forKey:@"verificationCode"];
        
        [[LoginUtil sharedLoginUtil] loginWithAppDict:dict success:^{
            [MBProgressHUD hiddenHUDView:self.view];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSString *error) {
            [MBProgressHUD hiddenHUDView:self.view];
            [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
        }];
    }else{
        if(userCode.length <= 0){
            [MBProgressHUD showHUDView:self.view text:@"用户名不能为空！" progressHUDMode:(YZProgressHUDModeShow)];
        }else if(password.length <= 0){
            [MBProgressHUD showHUDView:self.view text:@"密码不能为空！" progressHUDMode:(YZProgressHUDModeShow)];
        }else if(authCode.length <= 0){
            [MBProgressHUD showHUDView:self.view text:@"验证码不能为空！" progressHUDMode:(YZProgressHUDModeShow)];
        }else{
            [MBProgressHUD showHUDView:self.view text:@"未知错误！" progressHUDMode:(YZProgressHUDModeShow)];
        }
    }
    
    [self.view endEditing:YES];
}

#pragma mark - 添加注册方法
- (void)registerAction:(UIButton *)sender{
    DLog(@"点击了注册按钮...");
}

#pragma mark - 取消方法
- (void)cancelAction:(UIButton *)sender{
    MainTabBarController *mainTabBarController = [MainTabBarController sharedMainTabBarController];
    mainTabBarController.selectedIndex = 3;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - button倒计时
- (void)setTheCountdownButton:(UIButton *)button startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color{
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,0), 1.0 * NSEC_PER_SEC,0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束，关闭
        if (timeOut == 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //button.backgroundColor = mColor;
                [button setBackgroundImage:[UIImage imageWithColor:mColor] forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
                button.userInteractionEnabled =YES;
            });
        } else {
            int seconds = timeOut % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%0.1d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //button.backgroundColor = color;
                [button setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
                [button setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle]forState:UIControlStateNormal];
                button.userInteractionEnabled =NO;
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

