/************************************************************
 Class    : TouchIDViewController.m
 Describe : 用户指纹解锁视图界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-17
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "TouchIDViewController.h"
#import "YZTouchID.h"

@interface TouchIDViewController ()

@end

@implementation TouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finger_bg"]];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frameWidth / 2) - 35, 60, 70, 70)];
    logoImageView.image = [UIImage imageNamed:@"finger_headIcon"];
    //logoImageView.layer.masksToBounds = YES;// 隐藏边界
    //logoImageView.layer.cornerRadius = 12;// 将图层的边框设置为圆角
    [self.view addSubview:logoImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, WIDTH_SCREEN, 40)];
    titleLabel.text = [NSString stringWithFormat:@"您好，%@", [[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS] objectForKey:@"userName"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    
    UIButton *touchIDButton = [[UIButton alloc] init];
    [touchIDButton setBackgroundImage:[UIImage imageNamed:@"finger_print_locked"] forState:UIControlStateNormal];
    [touchIDButton setBackgroundImage:[UIImage imageNamed:@"finger_print_lockedHL"] forState:UIControlStateHighlighted];
    [touchIDButton addTarget:self action:@selector(touchVerification) forControlEvents:UIControlEventTouchDown];
    touchIDButton.frame = CGRectMake((self.view.frameWidth / 2) - 35, (self.view.frameHeight / 2) + 60, 70, 70);
    [self.view addSubview:touchIDButton];
    
    UILabel *touchIDLabel = [[UILabel alloc] init];
    touchIDLabel.frame = CGRectMake(0, (self.view.frameHeight / 2) + 140, WIDTH_SCREEN, 30);
    touchIDLabel.textAlignment = NSTextAlignmentCenter;
    touchIDLabel.text = @"点击唤醒指纹验证";
    touchIDLabel.font = [UIFont systemFontOfSize:15.0f];
    touchIDLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:touchIDLabel];
    
    [self touchVerification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 验证TouchID
- (void)touchVerification {
    
    YZTouchID *touchID = [[YZTouchID alloc] init];
    
    [touchID td_showTouchIDWithDescribe:nil BlockState:^(YZTouchIDState state, NSError *error) {
        
        if (state == YZTouchIDStateNotSupport) {    // 不支持TouchID
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert showAlertWithTitle:@"不支持指纹"
                         withSubtitle:@"对不起，当前设备不支持指纹，建议使用手势密码。"
                      withCustomImage:[UIImage imageNamed:@"alert_touch"]
                  withDoneButtonTitle:@"我知道了"
                           andButtons:nil];
            alert.colorScheme = alert.flatRed;
            
        } else if (state == YZTouchIDStateSuccess) {    // TouchID验证成功
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
}

@end
