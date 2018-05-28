/************************************************************
 Class    : GestureViewController.m
 Describe : 手势密码视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "GestureViewController.h"
#import "PCCircleView.h"
#import "PCCircleViewConst.h"
#import "PCLockLabel.h"
#import "PCCircleInfoView.h"
#import "PCCircle.h"

@interface GestureViewController ()<CircleViewDelegate>

/**
 *  提示Label
 */
@property (nonatomic, strong) PCLockLabel *msgLabel;

/**
 *  解锁界面
 */
@property (nonatomic, strong) PCCircleView *lockView;

/**
 *  infoView
 */
@property (nonatomic, strong) PCCircleInfoView *infoView;

/**
 * 记录密码错误次数
 */
@property (nonatomic, assign) int num;

@end

@implementation GestureViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 进来先清空存的第一个密码
    [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _num = 5; // 初始化可错误的次数
    
    [self.view setBackgroundColor:CircleViewBackgroundColor];

    // 1.界面相同部分生成器
    [self setupSameUI];
    
    // 2.界面不同部分生成器
    [self setupDifferentUI];
}

#pragma mark - 界面不同部分生成器
- (void)setupDifferentUI {
    switch (self.type) {
        case GestureViewControllerTypeSetting:
            [self setupSubViewsSettingVC];
            break;
        case GestureViewControllerTypeLogin:
            [self setupSubViewsLoginVC];
            break;
        default:
            break;
    }
}

#pragma mark - 界面相同部分生成器
- (void)setupSameUI {
    // 解锁界面
    PCCircleView *lockView = [[PCCircleView alloc] init];
    lockView.delegate = self;
    self.lockView = lockView;
    [self.view addSubview:lockView];
    
    float msgHeight = 14.0f;
    if(DEVICE_SCREEN_INCH_IPAD){
        msgHeight = 16.0f;
    }
    
    PCLockLabel *msgLabel = [[PCLockLabel alloc] init];
    msgLabel.frame = CGRectMake(0, 0, WIDTH_SCREEN, msgHeight);
    msgLabel.center = CGPointMake(WIDTH_SCREEN/2, CGRectGetMinY(lockView.frame) - 30);
    self.msgLabel = msgLabel;
    [self.view addSubview:msgLabel];
}

#pragma mark - 设置手势密码界面
- (void)setupSubViewsSettingVC {
    [self.lockView setType:CircleViewTypeSetting];
    
    self.title = @"设置手势密码";
    
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    
    PCCircleInfoView *infoView = [[PCCircleInfoView alloc] init];
    infoView.frame = CGRectMake(0, 0, CircleRadius * 2 * 0.6, CircleRadius * 2 * 0.6);
    infoView.center = CGPointMake(WIDTH_SCREEN/2, CGRectGetMinY(self.msgLabel.frame) - CGRectGetHeight(infoView.frame)/2 - 10);
    self.infoView = infoView;
    [self.view addSubview:infoView];
}

#pragma mark - 登陆手势密码界面
- (void)setupSubViewsLoginVC {
    [self.lockView setType:CircleViewTypeLogin];
    
    // 头像
    UIImageView  *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 65, 65);
    imageView.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/5);
    [imageView setImage:[UIImage imageNamed:@"gestures_lock"]];
    [self.view addSubview:imageView];
    
    [self.msgLabel showNormalMsg:gestureTextGesture];
    
    // 管理手势密码
    UIButton *leftBtn = [UIButton new];
    [self creatButton:leftBtn frame:CGRectMake(CircleViewEdgeMargin + 20, HEIGHT_SCREEN - 60, WIDTH_SCREEN/2, 20) title:@"管理手势密码" alignment:UIControlContentHorizontalAlignmentLeft tag:buttonTagManager];
    
    // 登录其他账户
    UIButton *rightBtn = [UIButton new];
    [self creatButton:rightBtn frame:CGRectMake(WIDTH_SCREEN/2 - CircleViewEdgeMargin - 20, HEIGHT_SCREEN - 60, WIDTH_SCREEN/2, 20) title:@"登陆其他账户" alignment:UIControlContentHorizontalAlignmentRight tag:buttonTagForget];
}

#pragma mark - 创建UIButton
- (void)creatButton:(UIButton *)btn frame:(CGRect)frame title:(NSString *)title alignment:(UIControlContentHorizontalAlignment)alignment tag:(NSInteger)tag {
    btn.frame = frame;
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:alignment];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didClickRightItem {
    DLog(@"点击了重设按钮");
    // 1.隐藏按钮
    self.navigationItem.rightBarButtonItem.title = nil;

    // 2.infoView取消选中
    [self infoViewDeselectedSubviews];

    // 3.msgLabel提示文字复位
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];

    // 4.清除之前存储的密码
    [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
}

#pragma mark - button点击事件
- (void)didClickBtn:(UIButton *)sender {
    DLog(@"%ld", (long)sender.tag);
    switch (sender.tag) {
        case buttonTagManager: {
            DLog(@"点击了管理手势密码按钮");
            break;
        }
        case buttonTagForget: {
            DLog(@"点击了登录其他账户按钮");
            break;
        }
        default:
            break;
    }
}

#pragma mark - circleView - delegate
#pragma mark - circleView - delegate - setting
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type connectCirclesLessThanNeedWithGesture:(NSString *)gesture {
    NSString *gestureOne = [PCCircleViewConst getGestureWithKey:gestureOneSaveKey];

    // 看是否存在第一个密码
    if ([gestureOne length]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重设" style:UIBarButtonItemStylePlain target:self action:@selector(didClickRightItem)];
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
    } else {
        DLog(@"密码长度不合法%@", gesture);
        [self.msgLabel showWarnMsgAndShake:gestureTextConnectLess];
    }
}

- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetFirstGesture:(NSString *)gesture {
    //DLog(@"获得第一个手势密码%@", gesture);
    [self.msgLabel showNormalMsg:gestureTextDrawAgain];
    
    // infoView展示对应选中的圆
    [self infoViewSelectedSubviewsSameAsCircleView:view];
}

- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal {
    //DLog(@"获得第二个手势密码%@",gesture);
    
    if (equal) {
        
        DLog(@"两次手势匹配！可以进行本地化保存了");
        
        // 设置参数状态值
        NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
        [settingDict setValue:[NSNumber numberWithBool:YES] forKey:@"gesturePwd"];
        BOOL res = [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
        if(!res){
            [MBProgressHUD showHUDView:self.view text:@"设置异常！" progressHUDMode:YZProgressHUDModeShow];
        }
        
        [self.msgLabel showNormalMsg:gestureTextSetSuccess];
        [PCCircleViewConst saveGesture:gesture Key:gestureFinalSaveKey];
        //[self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        
    } else {
        DLog(@"两次手势不匹配！");
        
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重设" style:UIBarButtonItemStylePlain target:self action:@selector(didClickRightItem)];
    }
}

#pragma mark - circleView - delegate - login or verify gesture
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal {
    // 此时的type有两种情况 Login or verify
    if (type == CircleViewTypeLogin) {
        if (equal) {
            DLog(@"登陆成功！");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            _num--;
            DLog(@"密码错误，你还可以输入%d次", _num);
            if(_num <= 0){
                [self.msgLabel showWarnMsgAndShake:@"手势密码输入错误次数过多，需注销后重新登录！"];
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert showAlertWithTitle:@"异常操作"
                             withSubtitle:@"手势密码输入错误次数过多，请注销后重新登录。"
                          withCustomImage:nil
                      withDoneButtonTitle:@"注销账户"
                               andButtons:nil];
                [alert makeAlertTypeWarning];

                [alert doneActionBlock:^{
                    [[LoginUtil sharedLoginUtil] clearLocalInfo];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                
            }else{
                [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError(_num)];
            }
        }
    } else if (type == CircleViewTypeVerify) {
        
        if (equal) {
            DLog(@"验证成功，跳转到设置手势界面");
            
        } else {
            DLog(@"原手势密码输入错误！");
            
        }
    }
}

#pragma mark - infoView展示方法
#pragma mark - 让infoView对应按钮选中
- (void)infoViewSelectedSubviewsSameAsCircleView:(PCCircleView *)circleView {
    for (PCCircle *circle in circleView.subviews) {
        
        if (circle.state == CircleStateSelected || circle.state == CircleStateLastOneSelected) {
            
            for (PCCircle *infoCircle in self.infoView.subviews) {
                if (infoCircle.tag == circle.tag) {
                    [infoCircle setState:CircleStateSelected];
                }
            }
        }
    }
}

#pragma mark - 让infoView对应按钮取消选中

- (void)infoViewDeselectedSubviews {
    [self.infoView.subviews enumerateObjectsUsingBlock:^(PCCircle *obj, NSUInteger idx, BOOL *stop) {
        [obj setState:CircleStateNormal];
    }];
}

@end
