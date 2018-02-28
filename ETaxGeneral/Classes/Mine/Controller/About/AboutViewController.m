/************************************************************
 Class    : AboutViewController.m
 Describe : 关于界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-16
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AboutViewController.h"
#import "AboutHeaderView.h"
#import "AboutFooterView.h"

@interface AboutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *data;                // 数据列表

@property (nonatomic, strong) AboutHeaderView *headerView;  // 顶部视图
@property (nonatomic, strong) AboutFooterView *footerView;  // 底部视图

@end

@implementation AboutViewController

static NSString * const reuseIdentifier = @"aboutTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于";
    
    _data = @[@"功能介绍", @"版权信息", @"去App Store评分"];
    
    [self.view setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    self.tableView.showsVerticalScrollIndicator = NO;// 隐藏纵向滚动条
    
    _headerView = [[AboutHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, floorf(HEIGHT_SCREEN/3.0f))];
    self.tableView.tableHeaderView = _headerView;
    
    float cellH = 43.0f;
    if(DEVICE_SCREEN_INCH_IPAD)
        cellH = 50.0f;
    
    float footerH = HEIGHT_SCREEN-HEIGHT_STATUS-HEIGHT_NAVBAR-floorf(HEIGHT_SCREEN/3.0f)-(cellH*3)-34-20;
    _footerView = [[AboutFooterView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, footerH)];
    self.tableView.tableFooterView = _footerView;
    // 注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float textFontSize = 17.0f;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;   // 右侧小箭头
    cell.textLabel.font = [UIFont systemFontOfSize:textFontSize];
    cell.textLabel.text = _data[indexPath.row];
    
    return cell;
}

#pragma mark 返回行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float cellH = 43.0f;
    if(DEVICE_SCREEN_INCH_IPAD)
        cellH = 50.0f;
    return cellH;
}

#pragma mark - cell点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 点击后将颜色变回来
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.textLabel.text isEqualToString:@"功能介绍"]){
        NSString *urlStr = [NSString stringWithFormat:@"%@taxnews/public/introductionIOS.htm", SERVER_URL];
        BaseWebViewController *introduceVC = [[BaseWebViewController alloc] initWithURL:urlStr];
        introduceVC.title = cell.textLabel.text;
        [self.navigationController pushViewController:introduceVC animated:YES];
    }
    if([cell.textLabel.text isEqualToString:@"去App Store评分"]){
        
    }
}

@end
