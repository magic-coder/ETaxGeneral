/************************************************************
 Class    : MineViewController.m
 Describe : 我的模块视图控制
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MineViewController.h"
#import "MineHeaderView.h"
#import "MineUtil.h"

@interface MineViewController () <MineHeaderViewDelegate>

@property (nonatomic, strong) MineHeaderView *headerView;

@property (nonatomic, assign) float headerViewH;        // 头部视图高度
@property (nonatomic, assign) float headerBottomViewH;  // 头部视图下方功能按钮栏高度

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 为适配iPad设备，按比例计算头部视图高度
    if(DEVICE_SCREEN_INCH_IPAD){
        _headerViewH = ceilf(HEIGHT_SCREEN*0.32f);
        _headerBottomViewH = floorf(_headerViewH*0.2f);
    }else{
        // 当设备为iPhone时进行固定值
        _headerViewH = HEIGHT_STATUS+HEIGHT_NAVBAR+160;
        _headerBottomViewH = 70;
    }
    
    // 不进行自动调整（否则顶部会自动留出安全距离[空白]）
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 设置头部视图
    _headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, _headerViewH)];
    _headerView.delegate = self;
    
    self.tableView.tableHeaderView = _headerView;
    
    // 初始化数据
    self.data = [[MineUtil sharedMineUtil] mineData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图即将显示
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置头视图数据
    if(IS_LOGIN){
        _headerView.nameText = [[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS] objectForKey:@"userName"];
    }else{
        _headerView.nameText = @"未登录";
    }
}

#pragma mark - UIScrollViewDelegate正在拖拽事件（下滑顶部视图放大效果）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < 0) {
        [_headerView.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView).with.mas_equalTo(offset.y);
            make.bottom.equalTo(_headerView).with.mas_equalTo(-_headerBottomViewH);
        }];
        
        [_headerView.nightShiftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView).with.offset(offset.y+HEIGHT_STATUS+10);
        }];
    }
}

#pragma mark - 头部视图按钮点击方法
- (void)mineHeaderViewBtnDidSelected:(UIButton *)sender {
    // 防止按钮重复点击
    CLICK_LOCK
    
    if(IS_LOGIN){
        if(0 == sender.tag){
            [self.navigationController pushViewController:[[NSClassFromString(@"AccountViewController") class] new] animated:YES];
        }
        if(1 == sender.tag){
            DLog(@"升级规则");
            BaseWebViewController *webVC = [[BaseWebViewController alloc] initWithURL:[NSString stringWithFormat:@"%@level/rule", SERVER_URL]];
            webVC.title = @"升级规则";
            [self.navigationController pushViewController:webVC animated:YES];
        }
        if(2 == sender.tag){
            DLog(@"积分情况统计");
            BaseWebViewController *webVC = [[BaseWebViewController alloc] initWithURL:[NSString stringWithFormat:@"%@level/index", SERVER_URL]];
            webVC.title = @"积分情况统计";
            [self.navigationController pushViewController:webVC animated:YES];
        }
        if(3 == sender.tag){
            DLog(@"每日签到");
            [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
            [YZNetworkingManager POST:@"level/obtion" parameters:@{@"scoreType" : @"1"} success:^(id responseObject) {
                [MBProgressHUD hiddenHUDView:self.view];
                if([responseObject objectForKey:@"msg"]){
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert showAlertWithTitle:@"已经签到"
                                 withSubtitle:[responseObject objectForKey:@"msg"]
                              withCustomImage:nil
                          withDoneButtonTitle:@"我知道了"
                                   andButtons:nil];
                    [alert makeAlertTypeCaution];
                }else{
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert showAlertWithTitle:@"签到成功"
                                 withSubtitle:@"恭喜您，获得10积分奖励，明天继续来签到哦😉"
                              withCustomImage:nil
                          withDoneButtonTitle:@"完成"
                                   andButtons:nil];
                    [alert makeAlertTypeSuccess];
                }
            } failure:^(NSString *error) {
                [MBProgressHUD hiddenHUDView:self.view];
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert showAlertWithTitle:@"签到失败"
                             withSubtitle:error
                          withCustomImage:nil
                      withDoneButtonTitle:@"确定"
                               andButtons:nil];
                [alert makeAlertTypeWarning];
            } invalid:^(NSString *msg) {
                [MBProgressHUD hiddenHUDView:self.view];
                SHOW_RELOGIN_VIEW
            }];
        }
    }else{
        SHOW_LOGIN_VIEW
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BaseTableModelGroup *group = [self.data objectAtIndex:indexPath.section];
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
    
    if([item.title isEqualToString:@"安全中心"]){
        if(IS_LOGIN){
            [self.navigationController pushViewController:[[NSClassFromString(@"SafeViewController") class] new] animated:YES];
        }else{
            SHOW_LOGIN_VIEW
        }
    }
    if([item.title isEqualToString:@"我的日程"]){
        if(IS_LOGIN){
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert showAlertWithTitle:@"操作提示"
                         withSubtitle:[NSString stringWithFormat:@"\"%@\"想要打开\"日历\"，是否允许？", [[Variable sharedVariable] appName]]
                      withCustomImage:[UIImage imageNamed:@"alert-calendar"]
                  withDoneButtonTitle:@"允许"
                           andButtons:@[@"取消"]];
            alert.colorScheme = alert.flatBlue;
            [alert doneActionBlock:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"] options:@{} completionHandler:nil];
            }];
        }else{
            SHOW_LOGIN_VIEW
        }
    }
    if([item.title isEqualToString:@"我的客服"]){
        [self.navigationController pushViewController:[[NSClassFromString(@"ServiceViewController") class] new] animated:YES];
    }
    if([item.title isEqualToString:@"设置"]){
        if(IS_LOGIN){
            [self.navigationController pushViewController:[[NSClassFromString(@"SettingViewController") class] new] animated:YES];
        }else{
            SHOW_LOGIN_VIEW
        }
    }
    if([item.title isEqualToString:@"系统评价"]){
        if(IS_LOGIN){
            NSString *urlStr = [NSString stringWithFormat:@"%@app/evaluation/index", SERVER_URL];
            BaseWebViewController *evaluationVC = [[BaseWebViewController alloc] initWithURL:urlStr];
            evaluationVC.title = @"系统评价";
            [self.navigationController pushViewController:evaluationVC animated:YES];
        }else{
            SHOW_LOGIN_VIEW
        }
    }
    if([item.title isEqualToString:@"关于"]){
        [self.navigationController pushViewController:[[NSClassFromString(@"AboutViewController") class] new] animated:YES];
    }
    if([item.title isEqualToString:@"测试"]){
        [self.navigationController pushViewController:[[NSClassFromString(@"TestViewController") class] new] animated:YES];
    }
}

@end
