/************************************************************
 Class    : GestureVerifyViewController.m
 Describe : 手势密码验证修改视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "GestureVerifyViewController.h"
#import "PCCircleViewConst.h"
#import "PCCircleView.h"
#import "PCLockLabel.h"
#import "GestureViewController.h"

@interface GestureVerifyViewController ()<CircleViewDelegate>

/**
 *  文字提示Label
 */
@property (nonatomic, strong) PCLockLabel *msgLabel;

/**
 * 记录密码错误次数
 */
@property (nonatomic, assign) int num;

@end

@implementation GestureVerifyViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:CircleViewBackgroundColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"验证手势密码";
    
    _num = 5; // 初始化可错误的次数
    
    PCCircleView *lockView = [[PCCircleView alloc] init];
    lockView.delegate = self;
    [lockView setType:CircleViewTypeVerify];
    [self.view addSubview:lockView];
    
    PCLockLabel *msgLabel = [[PCLockLabel alloc] init];
    msgLabel.frame = CGRectMake(0, 0, WIDTH_SCREEN, 14);
    msgLabel.center = CGPointMake(WIDTH_SCREEN/2, CGRectGetMinY(lockView.frame) - 30);
    [msgLabel showNormalMsg:gestureTextOldGesture];
    self.msgLabel = msgLabel;
    [self.view addSubview:msgLabel];
}

#pragma mark - login or verify gesture
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal {
    if (type == CircleViewTypeVerify) {
        
        if (equal) {
            DLog(@"验证成功");
            
            if (self.isToSetNewGesture) {
                GestureViewController *gestureVC = [[GestureViewController alloc] init];
                gestureVC.type = GestureViewControllerTypeSetting;
                [self.navigationController pushViewController:gestureVC animated:YES];
            } else {
                
                // 设置参数状态值
                NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
                [settingDict setValue:[NSNumber numberWithBool:NO] forKey:@"gesturePwd"];
                BOOL res = [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
                if(!res){
                    [MBProgressHUD showHUDView:self.view text:@"设置异常！" progressHUDMode:YZProgressHUDModeShow];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            
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
                    [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
                }];
                
            }else{
                [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError(_num)];
            }
        }
    }
}

@end
