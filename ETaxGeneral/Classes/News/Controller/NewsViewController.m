/************************************************************
 Class    : NewsViewController.h
 Describe : 首页新闻展示视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "NewsModel.h"
#import "NewsUtil.h"
#import "MJRefresh.h"
#import "TGRefresh.h"

#import "MenuView.h"
#import "LeftMenuView.h"

#define NAVBAR_CHANGE_POINT 50

@interface NewsViewController () <UITableViewDelegate, UITableViewDataSource, YZCycleScrollViewDelegate, MenuViewDelegate, LeftMenuViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MenuView *menu;                               // 左滑菜单
@property (nonatomic, strong) LeftMenuView *demo;                           // 左侧菜单

@property (nonatomic, assign) int pageNo;                                   // 页码值
@property (nonatomic, assign) int totalPage;                                // 最大页

@property (nonatomic, strong) NSMutableArray *data;                         // 数据列表
@property (nonatomic, strong) YZCycleScrollView *cycleScrollView;           // 顶部轮播焦点图

@property (nonatomic, assign) BOOL isInit;                                  // 初始化标志
@property (nonatomic, strong) NSTimer *timer;                               // 自定义计时器，获取VPN认证状态

@end

@implementation NewsViewController

static NSString * const reuseIdentifier = @"newsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isInit = YES;  // 设置初始化标志
    
    self.title = @"首页";
    
    //[self.navigationController.navigationBar yz_setBackgroundColor:[UIColor clearColor]];
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    //self.jz_navigationBarBackgroundAlpha = 0.0f;
    
    // 导航栏平滑过渡，延展视图包含部包含不透明的NavigationBar
//    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self navigationInitialize];
    
    [self.view addSubview:self.tableView];
    
    [self.view sendSubviewToBack:self.tableView];// 设置视图层级为最下层
    [self initializeSlideMenu];// 初始化左侧滑动菜单
    
    [self autoLayout];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自动布局
- (void)autoLayout{

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}
#pragma mark - 视图即将显示
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar yz_initialize];

    [self scrollViewDidScroll:self.tableView];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    // 判断是否登录
    if(IS_LOGIN){
        if(_isInit){
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
        }
    }else{
        SHOW_LOGIN_VIEW
    }
    
}

#pragma mark - 视图即将销毁方法
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar yz_reset];
}
#pragma mark - 滚动屏幕渐进渐出顶部导航栏
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.navigationController.navigationBar yz_changeColor:DEFAULT_BLUE_COLOR WithScrollView:scrollView AndValue:90.0f];
}

#pragma mark - 定时器循环调用方法
- (void)timerCallBack {
    if([Variable sharedVariable].vpnSuccess){   // 如果VPN认证成功，开始加载数据
        
        // 释放定时器，销毁 timer
        if([self.timer isValid]){
            [self.timer invalidate];
            self.timer = nil;
        }
        
        // 初始化数据
        if(nil == _data || _data.count <= 0){
            _isInit = NO;
            [self.tableView.tg_header beginRefreshing]; // 马上进入刷新状态
        }
    }
}

#pragma mark - 初始化数（下拉刷新方法）
- (void)initializeData {
    _pageNo = 1;
    
    // 请求数据
    [[NewsUtil sharedNewsUtil] initDataWithPageSize:10 success:^(NSDictionary *dataDict) {
        // 创建数据对象（初始化）
        _data = [[NSMutableArray alloc] init];
        
        // 顶部轮播焦点图数据
        
        NSDictionary *loopDict = [dataDict objectForKey:@"loopResult"];
        NSArray *titles = [loopDict objectForKey:@"titles"];
        NSArray *images = [loopDict objectForKey:@"images"];
        NSArray *urls = [loopDict objectForKey:@"urls"];
        
        
//        NSArray *titles = @[@"腾讯马化腾，谈2018区块链对科技的影响", @"阿里巴巴技术这么年所产生的影响力", @"Github遭遇史上最强DDos攻击，持续14分钟"];
//        NSArray *images = @[@"cycle_1", @"cycle_2", @"cycle_3"];
//        NSArray *urls = @[@"https://www.qq.com", @"https://www.alibaba.com", @"https://www.github.com"];
        
        _cycleScrollView = [[YZCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, floorf((CGFloat)WIDTH_SCREEN/1.8)) titles:titles images:images urls:urls autoPlay:YES delay:2.7f];
        _cycleScrollView.delegate = self;
        self.tableView.tableHeaderView = _cycleScrollView;
        
        // 首页税闻列表数据
        NSArray *newsArray = [dataDict objectForKey:@"newsResult"];
        for(NSDictionary *newsDict in newsArray){
            NewsModel *model = [NewsModel createWithDictionary:newsDict];
            [_data addObject:model];
        }
        
        [self.tableView.tg_header endRefreshing];   // 结束头部刷新动画

        _totalPage = [[dataDict objectForKey:@"totalPage"] intValue];
        if(_totalPage > 1 && !self.tableView.mj_footer)
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];    // 设置上拉加载
        
        
        [self.tableView reloadData];    // 重新加载数据
        
        // 读取系统设置（播放音效）
        NSDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
        BOOL sysVoiceOn = [[settingDict objectForKey:@"sysVoice"] boolValue];
        if(sysVoiceOn){
            [[BaseHandleUtil sharedBaseHandleUtil] playSoundEffect:@"refreshsound" type:@"caf"];// 刷新时音效
        }
        
    } failure:^(NSString *error) {
        [self.tableView.tg_header endRefreshing];   // 结束头部刷新动画
        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow]; // 错误提示
    } invalid:^(NSString *msg) {
        [self.tableView.tg_header endRefreshing];   // 结束头部刷新动画
        
        SHOW_RELOGIN_VIEW
    }];

}

#pragma mark - 加载更多数据
- (void)loadMoreData {
    
    _pageNo++;
    
    [[NewsUtil sharedNewsUtil] moreDataWithPageNo:_pageNo pageSize:10 success:^(NSArray *dataArray) {
        
        for(NSDictionary *dataDict in dataArray){
            NewsModel *model = [NewsModel createWithDictionary:dataDict];
            [_data addObject:model];
        }
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];// 结束底部刷新
        
    } failure:^(NSString *error) {
        _pageNo--;
        [self.tableView.mj_footer endRefreshing];   // 结束底部刷新
        
        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];// 错误提示
    } invalid:^(NSString *msg) {
        _pageNo--;
        [self.tableView.mj_footer endRefreshing];   // 结束底部刷新

        SHOW_RELOGIN_VIEW
    }];
    
}

#pragma mark - <YZCycleScrollViewDelegate>顶部轮播图点击代理方法
- (void)cycleScrollViewDidSelectedImage:(YZCycleScrollView *)cycleScrollView index:(int)index {
    BaseWebViewController *webVC = [[BaseWebViewController alloc] initWithURL:cycleScrollView.urls[index]];
    webVC.title = cycleScrollView.titles[index];
    webVC.jz_navigationBarBackgroundAlpha = 1.0f;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source
#pragma mark 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1.缓存中取
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    // 2.创建
    if (!cell) {
        cell = [[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    // 3.设置数据
    cell.model = [_data objectAtIndex:indexPath.row];
    // 4.返回cell
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 点击后将颜色变回来
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    BaseWebViewController *baseWebVC = [[BaseWebViewController alloc] initWithURL:cell.model.url];
    baseWebVC.title = cell.model.showTitle;
    baseWebVC.jz_navigationBarBackgroundAlpha = 1.0f;
    [self.navigationController pushViewController:baseWebVC animated:YES];
    
    //[self.navigationController pushViewController:[NSClassFromString(@"TestViewController") new] animated:YES];

}

// 设置cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsModel *model = [_data objectAtIndex:indexPath.row];
    if(model.cellHeight > 0){
        return model.cellHeight;
    }
    return 0;
}

#pragma mark - 懒加载方法
- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        /*
        if(DEVICE_SCREEN_INCH_5_8){
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN-HEIGHT_TABBAR-34) style:UITableViewStylePlain];
        }else{
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN-HEIGHT_TABBAR) style:UITableViewStylePlain];
        }
         */
        _tableView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        //_tableView.showsVerticalScrollIndicator = NO;// 隐藏纵向滚动条
        //_tableView.rowHeight = 80;// 设置基本行高
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;// 自定义cell样式
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];// 去除底部多余分割线
        _tableView.delegate = self;
        _tableView.dataSource = self;
        // 设置下拉刷新
        //_tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(initializeData)];
        // 设置下拉刷新视图
        _tableView.tg_header = [TGRefreshOC  refreshWithTarget:self action:@selector(initializeData) config:nil];
    }
    return _tableView;
}

#pragma mark - 初始化左侧快捷滑动菜单
- (void)initializeSlideMenu {
    
    _demo = [[LeftMenuView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height)];
    _demo.delegate = self;
    
    self.menu = [[MenuView alloc] initWithDependencyView:self.view MenuView:_demo isShowCoverView:YES];
    self.menu.delegate = self;
}

#pragma mark - 左侧滑动菜单主代理方法，菜单即将显示方法（进行设置数据）
- (void)willAppear {
    [_demo loadData];// 设置姓名、机构名称
}
#pragma mark - 左侧滑动菜单主代理方法，菜单即将隐藏方法（清空原有数据）
- (void)willDisappear {
    [_demo clearData]; // 清空展示的数据，下次显示进行重新设置
}

#pragma mark - 左侧菜单功能点击代理方法
- (void)leftMenuViewClick:(NSInteger)tag {
    [self.menu hidenWithAnimation];// 隐藏左侧菜单
    
    if(0 == tag){
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
        backItem.title=@"首页";
        super.navigationItem.backBarButtonItem = backItem;
        UIViewController *vc = [[NSClassFromString(@"AccountViewController") class] new];
        vc.jz_navigationBarBackgroundAlpha = 1.0f;
        [super.navigationController pushViewController:vc animated:YES];
    }
    if(1 == tag){
        [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
        [YZNetworkingManager POST:@"level/obtion" parameters:@{@"scoreType" : @"1"} success:^(id responseObject) {
            [MBProgressHUD hiddenHUDView:self.view];
            if([responseObject objectForKey:@"msg"]){
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert showAlertWithTitle:@"已经签到"
                             withSubtitle:[responseObject objectForKey:@"msg"]
                          withCustomImage:nil
                      withDoneButtonTitle:@"好的"
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
    if(2 == tag){
        BaseWebViewController *introduceVC = [[BaseWebViewController alloc] initWithURL:[NSString stringWithFormat:@"%@taxnews/public/introductionIOS.htm", SERVER_URL]];
        introduceVC.jz_navigationBarBackgroundAlpha = 1.0f;
        introduceVC.title =  @"功能介绍";
        [super.navigationController pushViewController:introduceVC animated:YES];
    }
    if(3 == tag){
        BaseWebViewController *questionVC = [[BaseWebViewController alloc] initWithURL:[NSString stringWithFormat:@"%@taxnews/public/comProblemIOS.htm", SERVER_URL]];
        questionVC.jz_navigationBarBackgroundAlpha = 1.0f;
        questionVC.title =  @"常见问题";
        [super.navigationController pushViewController:questionVC animated:YES];
    }
    if(4 == tag){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://029-87663504"] options:@{} completionHandler:nil];
    }
    if(5 == tag){
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
        backItem.title=@"首页";
        super.navigationItem.backBarButtonItem = backItem;
        UIViewController *vc = [[NSClassFromString(@"SettingViewController") class] new];
        vc.jz_navigationBarBackgroundAlpha = 1.0f;
        [super.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 初始化导航栏样式UI
- (void)navigationInitialize {
    //导航栏左按钮
    UIImage *imgLeft = [[UIImage imageNamed:@"navigation_mine"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:imgLeft style:UIBarButtonItemStylePlain target:self action:@selector(navigationLeftBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //导航栏右按钮
    /*
    UIImage *imgRight = [[UIImage imageNamed:@"navigation_right"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:imgRight style:UIBarButtonItemStylePlain target:self action:@selector(navigationRightBtnItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    */
    
    //中间搜索框
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN - 100, 26)];
    searchTextField.layer.cornerRadius = 5;
    searchTextField.layer.borderWidth = .5;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.layer.borderColor = RgbColor(255.0f, 255.0f, 255.0f, 0.0f).CGColor;
    searchTextField.backgroundColor = RgbColor(255.0f, 255.0f, 255.0f, 0.26f);
    //searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    //searchTextField.alpha = 0.3f;
    self.navigationItem.titleView = searchTextField;
    
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(searchTextField.originX+4, searchTextField.originY+1, 24, 24)];
    imgSearch.image = [UIImage imageNamed:@"app_common_searchHL"];
    [self.navigationItem.titleView addSubview:imgSearch];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchTextField.originX+26+10, searchTextField.originY, searchTextField.frameWidth-imgSearch.frameWidth-20, 26)];
    searchLabel.textColor = [UIColor whiteColor];
    searchLabel.font = [UIFont systemFontOfSize:14.0f];
    searchLabel.text = @"热门搜索";
    [self.navigationItem.titleView addSubview:searchLabel];
    
    UIButton *btn_search_frame = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_search_frame.frame = searchTextField.frame;
    btn_search_frame.tag = 1;
    [btn_search_frame addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem.titleView addSubview:btn_search_frame];   // 搜索按钮
}

- (void)searchBtnClick:(UIButton *)sender{
    UIViewController *viewController = [[NSClassFromString(@"AppSearchViewController") class] new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)navigationLeftBtnItemClick:(UIBarButtonItem *)sender{
    [self.menu show];
}

- (void)navigationRightBtnItemClick:(UIBarButtonItem *)sender{
}

@end
