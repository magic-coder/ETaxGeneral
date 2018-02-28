/************************************************************
 Class    : ServiceViewController.m
 Describe : 我的客服界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "ServiceViewController.h"
#import "MineUtil.h"

@interface ServiceViewController ()

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的客服";
    self.data = [[MineUtil sharedMineUtil] serviceData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BaseTableModelGroup *group = [self.data objectAtIndex:indexPath.section];
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
    
    UIViewController *viewController = nil;
    if([item.title isEqualToString:@"客服电话"]){
        NSString *str = [NSString stringWithFormat:@"tel://%@", item.subTitle];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }
    if([item.title isEqualToString:@"客服邮箱"]){
        NSString *str = [NSString stringWithFormat:@"mailto://%@", item.subTitle];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }
    if([item.title isEqualToString:@"常见问题"]){
        BaseWebViewController *questionVC = [[BaseWebViewController alloc] initWithURL:[NSString stringWithFormat:@"%@taxnews/public/comProblemIOS.htm", SERVER_URL]];
        viewController = questionVC;
    }
    
    if(nil != viewController){
        viewController.title = item.title;
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

@end
