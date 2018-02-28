/************************************************************
 Class    : SettingViewController.m
 Describe : 设置界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "SettingViewController.h"
#import "MineUtil.h"

@interface SettingViewController () <BaseTableViewControllerDelegate>

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    self.delegate = self;
    self.data = [[MineUtil sharedMineUtil] settingData];
    
    // 增加监听（监听程序从后台切入前台）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图即将销毁方法
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 进入前台方法
- (void)appHasGoneInForeground:(NSNotificationCenter *)defaultCenter{
    //self.data = [[MineUtil sharedMineUtil] settingData];
}

#pragma mark - 设置Cell的点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BaseTableModelGroup *group = [self.data objectAtIndex:indexPath.section];
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
    
    if([item.title isEqualToString:@"清理缓存"]){
        [YZBottomSelectView showBottomSelectViewWithTitle:@"清理后，需要重新加载图片等信息" cancelButtonTitle:@"取消" destructiveButtonTitle:@"立即清理" otherButtonTitles:nil handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            if(-1 == index){
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.animationType = MBProgressHUDAnimationZoom;
                hud.bezelView.backgroundColor = [UIColor blackColor];   // 设置背景颜色
                hud.contentColor = [UIColor whiteColor];    // 设置字体颜色
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    // Switch to determinate mode
                    dispatch_async(dispatch_get_main_queue(), ^{
                        hud.mode = MBProgressHUDModeDeterminate;
                        hud.label.text = @"正在清理...";
                    });
                    float progress = 0.0f;
                    while (progress < 1.0f) {
                        progress += 0.01f;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            hud.progress = progress;
                        });
                        usleep(30000);
                    }
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                        
                        UIImage *image = [UIImage imageNamed:@"common_mark_success"];
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                        hud.customView = imageView;
                        hud.mode = MBProgressHUDModeCustomView;
                        hud.label.text = @"清理完成！";
                        
                        // 重新加载数据
                        self.data = [[MineUtil sharedMineUtil] settingData];
                        [self.tableView reloadData];
                    }];
                    [[SDImageCache sharedImageCache] clearMemory];
                    sleep(1);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                });
            }
        }];
    }
}

#pragma mark - 代理Switch的点击方法
- (void)baseTableViewControllerSwitchChanged:(UISwitch *)sender {
    NSNumber *open = [NSNumber numberWithBool:YES];
    NSNumber *close = [NSNumber numberWithBool:NO];
    
    NSMutableDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    
    NSInteger tag = sender.tag;
    if([sender isOn]){
        // 声音
        if(tag == 452){
            [settingDict setObject:open forKey:@"voice"];
        }
        // 震动
        if(tag == 453){
            [settingDict setObject:open forKey:@"shake"];
        }
        // 系统音效
        if(tag == 454){
            [settingDict setObject:open forKey:@"sysVoice"];
        }
    }else{
        // 声音
        if(tag == 452){
            [settingDict setObject:close forKey:@"voice"];
        }
        // 震动
        if(tag == 453){
            [settingDict setObject:close forKey:@"shake"];
        }
        // 系统音效
        if(tag == 454){
            [settingDict setObject:close forKey:@"sysVoice"];
        }
    }
    
    // 写入本地SandBox设置文件中
    BOOL res = [[BaseSettingUtil sharedBaseSettingUtil] writeSettingData:settingDict];
    if(!res){
        [MBProgressHUD showHUDView:self.view text:@"设置失败！" progressHUDMode:YZProgressHUDModeShow];
    }
}

@end
