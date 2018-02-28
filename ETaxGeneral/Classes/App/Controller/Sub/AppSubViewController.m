/************************************************************
 Class    : AppSubViewController.m
 Describe : 应用第二级菜单列表
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-09
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppSubViewController.h"
#import "AppSubViewCell.h"
#import "AppModel.h"
#import "AppUtil.h"

@interface AppSubViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) NSString *pno;
@property (nonatomic, strong) NSString *level;

@end

@implementation AppSubViewController

static NSString * const reuseIdentifier = @"appSubCell";

- (instancetype)initWithPno:(NSString *)pno level:(NSString *)level{
    if(self = [super init]){
        _pno = pno;
        _level = level;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    [self.tableView registerClass:[AppSubViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    _data = [[AppUtil sharedAppUtil] loadSubDataWithPno:_pno level:_level];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置顶部状态栏字体为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppSubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    [cell setItem:[_data objectAtIndex:indexPath.row]];
    indexPath.row == 0 ? [cell setTopLineStyle:AppSubViewCellLineStyleFill] : [cell setTopLineStyle:AppSubViewCellLineStyleNone];
    indexPath.row == _data.count - 1 ? [cell setBottomLineStyle:AppSubViewCellLineStyleFill] : [cell setBottomLineStyle:AppSubViewCellLineStyleDefault];
    return cell;
}
#pragma mark 返回行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63.0f;
}

#pragma mark 点击行触发点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 获取当前点击的cell
    AppSubViewCell *cell = (AppSubViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *viewController = nil;
    
    NSString *url = cell.item.url;
    DLog(@"url %@ ", url);
    if(url == nil || url.length <= 0){
        int level = [cell.item.level intValue]+1;
        viewController = [[AppSubViewController alloc] initWithPno:cell.item.no level:[NSString stringWithFormat:@"%d", level]];
    }else{
        viewController = [[BaseWebViewController alloc] initWithURL:url];
    }
    
    viewController.title = cell.item.title; // 设置标题
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
