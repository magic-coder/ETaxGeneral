/************************************************************
 Class    : SafeViewController.m
 Describe : 安全中心界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "SafeViewController.h"
#import "GestureViewController.h"
#import "GestureVerifyViewController.h"
#import "YZTouchID.h"
#import "MineUtil.h"

@interface SafeViewController () <BaseTableViewControllerDelegate>

@end

@implementation SafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"安全中心";
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;// 设置顶部状态栏字体为黑色
     self.navigationController.navigationBar.tintColor = DEFAULT_BLUE_COLOR;// 设置导航栏itemBar字体颜色
     self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };// 设置导航栏title标题字体颜色
     
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;// 设置顶部状态栏字体为白色
     self.navigationController.navigationBar.tintColor = [UIColor whiteColor];// 设置导航栏itemBar字体颜色
     self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };// 设置导航栏title标题字体颜色
     */
    
    self.data = [[MineUtil sharedMineUtil] safeData];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BaseTableModelGroup *group = [self.data objectAtIndex:indexPath.section];
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
    
    if([item.title isEqualToString:@"修改手势密码"]){
        GestureVerifyViewController *gestureVerifyVC = [[GestureVerifyViewController alloc] init];
        gestureVerifyVC.isToSetNewGesture = YES;
        [self.navigationController pushViewController:gestureVerifyVC animated:YES];
    }
}

#pragma mark - <BaseTableViewControllerDelegate>代理方法
- (void)baseTableViewControllerSwitchChanged:(UISwitch *)sender{
    NSInteger tag =  sender.tag;
    if(tag == 422){// 手势密码
        [self gestureSettingVerification:sender];
    }
    if(tag == 423){// 指纹识别
        [self touchVerification:sender];
    }
}

#pragma mark - 设置、验证手势密码
- (void)gestureSettingVerification:(UISwitch *)sender {
    if(sender.on){
        GestureViewController *gestureVC = [[GestureViewController alloc] init];
        gestureVC.type = GestureViewControllerTypeSetting;
        [self.navigationController pushViewController:gestureVC animated:YES];
    }else{
        GestureVerifyViewController *gestureVerifyVC = [[GestureVerifyViewController alloc] init];
        [self.navigationController pushViewController:gestureVerifyVC animated:YES];
    }
}

#pragma mark - 验证TouchID
- (void)touchVerification:(UISwitch *)sender {
    
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
            
            sender.on = !sender.isOn;
        } else if (state == YZTouchIDStateSuccess) {    // TouchID验证成功
            sender.on = sender.isOn;
        }else{
            sender.on = !sender.isOn;
        }
        
        // ps:以上的状态处理并没有写完全!
        // 在使用中你需要根据回调的状态进行处理,需要处理什么就处理什么
        NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
        [settingDict setValue:[NSNumber numberWithBool:sender.isOn] forKey:@"touchID"];
        
        BOOL res = [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
        if(!res){
            [MBProgressHUD showHUDView:self.view text:@"设置异常！" progressHUDMode:YZProgressHUDModeShow];
        }
        
    }];
}

@end
