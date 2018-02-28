/************************************************************
 Class    : BaseViewController.h
 Describe : 最基本的视图控制器，所有视图控制器的根试图控制器，提供通用属性及方法
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2018-02-27
 Version  : 1.0
 Declare  : Copyright © 2018 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图即将显示时调用的方法
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 处理顶部导航栏切换效果颜色
    DLog(@"Previous visible view controller is %@", self.navigationController.jz_previousVisibleViewController);
}

#pragma mark - 视图即将消失时调用的方法
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 处理顶部导航栏切换效果颜色
    if (self.navigationController.jz_operation == UINavigationControllerOperationPop) {
        DLog(@"Controller will be poped.");
    } else if (self.navigationController.jz_operation == UINavigationControllerOperationPush) {
        DLog(@"Controller will push to another.");
    }
}

@end
