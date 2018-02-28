/************************************************************
 Class    : AccountViewController.m
 Describe : 我的信息界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AccountViewController.h"
#import "MineUtil.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"个人信息";
    self.data = [[MineUtil sharedMineUtil] accountData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BaseTableModelGroup *group = [self.data objectAtIndex:indexPath.section];
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
    
    if([item.title isEqualToString:@"退出登录"]){
        [YZBottomSelectView showBottomSelectViewWithTitle:@"退出登录后下次使用时需重新登录，您确定要退出吗？" cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles:nil handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            
            if(-1 == index){
                [[LoginUtil sharedLoginUtil] logout];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    }
    
}

@end
