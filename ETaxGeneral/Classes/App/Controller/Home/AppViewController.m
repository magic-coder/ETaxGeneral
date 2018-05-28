/************************************************************
 Class    : AppViewController.m
 Describe : 使用模块视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppViewController.h"
#import "AppSubViewController.h"
#import "AppTopView.h"
#import "AppHeaderView.h"
#import "AppFooterView.h"
#import "AppBorderView.h"
#import "AppView.h"
#import "AppModel.h"
#import "AppUtil.h"

#pragma mark 应用类型分组ENUM
typedef NS_ENUM(NSInteger, AppViewType) {
    AppViewTypeMine,    // 应用视图类型，我的应用
    AppViewTypeOther    // 应用视图类型，其他应用
};

@interface AppViewController () <AppTopViewDelegate, AppViewDelegate>

// 控制长按移动的参数
@property (nonatomic, assign) CGPoint viewPoint;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSInteger beginPos;

// 视图组件
@property (nonatomic, strong) AppTopView *appTopView;
@property (nonatomic, strong) BaseScrollView *baseScrollView;
@property (nonatomic, strong) UIView *pullHiddenView;

@property (nonatomic, strong) AppHeaderView *mineHeaderView;
@property (nonatomic, strong) UIView *mineFooterView;

@property (nonatomic, strong) AppHeaderView *otherHeaderView;
@property (nonatomic, strong) AppFooterView *otherFooterView;

// 视图参数
@property (nonatomic, assign) float mineAppViewHeight;
@property (nonatomic, assign) float otherAppViewHeight;
@property (nonatomic, assign) BOOL adjustStatus;                    // 是否进行了重新排序操作
@property (nonatomic, assign, getter=isReload) BOOL reload;         // 是否从新加载数据

@property (nonatomic, strong) NSMutableArray *mineDataArray;        // 我的应用数据
@property (nonatomic, strong) NSMutableArray *mineBorderViewArray;  // 我的应用底层虚线视图
@property (nonatomic, strong) NSMutableArray *mineAppViewArray;     // 我是应用视图

@property (nonatomic, strong) NSMutableArray *allDataArray;        // 其他/更多应用数据

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    [self.view addSubview:self.appTopView]; // 添加App最顶部头视图
    [self.view addSubview:self.baseScrollView];
    
    // 防止UIScrollView顶部空隙
    if (@available(iOS 11.0, *)) {
        self.baseScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.baseScrollView addSubview:self.pullHiddenView];
    [self.baseScrollView addSubview:self.mineHeaderView];
    
    // 设置视图层级关系
    [self.view bringSubviewToFront:self.appTopView];// 设置视图层级为最上层
    [self.view sendSubviewToBack:self.baseScrollView];// 设置视图层级为最底下
    
    // 初始化最新数据
    if(IS_LOGIN){
        [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:APP_FILE];
        [[AppUtil sharedAppUtil] initAppDataSuccess:^(NSMutableDictionary *dataDict) {
            [self initAppData:dataDict];
        } failure:^(NSString *error) {
        } invalid:^(NSString *msg) {
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图即将显示调用的方法
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;// 设置顶部状态栏字体为白色
    
    if(IS_LOGIN){
        if(self.isReload)
            [[BaseSandBoxUtil sharedBaseSandBoxUtil] removeFileName:APP_FILE];
        // 获取应用数据
        NSDictionary *appData = [[AppUtil sharedAppUtil] loadAppData];
        if(appData){
            [self initAppData:appData];
        }else{
            [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
            [[AppUtil sharedAppUtil] initAppDataSuccess:^(NSMutableDictionary *dataDict) {
                [MBProgressHUD hiddenHUDView:self.view];
                [self initAppData:dataDict];
            } failure:^(NSString *error) {
                [MBProgressHUD hiddenHUDView:self.view];
                [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
            } invalid:^(NSString *msg) {
                [MBProgressHUD hiddenHUDView:self.view];
                SHOW_RELOGIN_VIEW
            }];
        }
    }else{
        SHOW_LOGIN_VIEW
    }
}

#pragma mark - 视图已经显示调用的方法
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.reload = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];// 设置导航栏itemBar字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };// 设置导航栏title标题字体颜色
}

#pragma mark - 视图即将销毁调用的方法
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if(_adjustStatus)
        [self editMineAppDataSort];
    
}

#pragma mark - 开始处理加载数据
- (void)initAppData:(NSDictionary *)data {
    
    // 重新构建应用前先移除以前的
    NSArray *subViews = [self.baseScrollView subviews];
    for(UIView *view in subViews){
        if (![view isEqual:self.mineHeaderView] && ![view isEqual:self.pullHiddenView]) {
            [view removeFromSuperview];
        }
    }
    
    _mineDataArray = [NSMutableArray array];
    _mineDataArray = [data objectForKey:@"mineData"];
    
    _allDataArray = [NSMutableArray array];
    _allDataArray = [data objectForKey:@"allGroupData"];
    [self initMineAppBorderView];
    [self initAppViewData:_allDataArray type:AppViewTypeOther];
    [self.baseScrollView setContentSize:CGSizeMake(WIDTH_SCREEN, _otherAppViewHeight + HEIGHT_STATUS + 15)];
}

#pragma mark - 添加我的应用图标底层虚线边框
- (void)initMineAppBorderView {
    
    _mineBorderViewArray = [NSMutableArray array];
    
    int itemWidth = ((WIDTH_SCREEN - 50) / 4);
    for (int i = 0; i < _mineDataArray.count; i++) {
        CGRect frame = CGRectMake((i%4)*(itemWidth+10)+10, (i/4)*(itemWidth+10)+10+self.mineHeaderView.frameBottom, itemWidth-10, itemWidth-10);
        frame = CGRectInset(frame, 1, 1);
        AppBorderView *appBorderView = [[AppBorderView alloc] initWithFrame:frame];
        [self.baseScrollView addSubview:appBorderView];
        [_mineBorderViewArray addObject:appBorderView];
    }
    [self initAppViewData:_mineDataArray type:AppViewTypeMine];
}

#pragma mark - 根据类型初始化创建应用模块视图（包含：我的应用、其他/更多应用）
- (void)initAppViewData:(NSMutableArray *)array type:(AppViewType)type{
    if(AppViewTypeMine == type)
        _mineAppViewArray = [NSMutableArray array];
    
    int viewWidth = ((WIDTH_SCREEN - 25) / 4);
    UIView *lastGroupView;
    for (int i = 0; i < array.count; i++) {
        if(AppViewTypeMine == type){    // 我的应用
            AppModelItem *item = [AppModelItem createWithDictionary:array[i]];
            AppView *appView = [[AppView alloc] init];
            appView.delegate = self;
            appView.item = item;
            appView.tag = i;
            appView.frame = CGRectMake((i%4)*(viewWidth+5)+5, (i/4)*(viewWidth+5)+self.mineHeaderView.frameBottom, viewWidth, viewWidth);
            
            if(i == array.count - 1){
                _mineAppViewHeight = appView.frameBottom;
                [self.baseScrollView addSubview:self.mineFooterView];// 添加底部视图
            }
            
            // 添加长按手势
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
            [appView addGestureRecognizer:longGesture];
            
            [self.baseScrollView addSubview:appView];
            [_mineAppViewArray addObject:appView];
        }
        if(AppViewTypeOther == type){   // 其他应用(更多应用)
            NSDictionary *groupDic = array[i];
            
            AppHeaderView *groupHeaderView = [[AppHeaderView alloc] initWithFrame:CGRectMake(0, !lastGroupView ? self.mineFooterView.frameBottom : lastGroupView.frameBottom, WIDTH_SCREEN, 30.0f)];
            groupHeaderView.title = groupDic[@"groupName"];
            [self.baseScrollView addSubview:groupHeaderView];// 添加分组头部视图
            
            NSArray *otherAppDataArr = groupDic[@"appArray"];
            for (int j = 0; j < otherAppDataArr.count; j++) {
                AppModelItem *item = [AppModelItem createWithDictionary:otherAppDataArr[j]];
                AppView *appView = [[AppView alloc] initWithFrame:CGRectMake((j%4)*(viewWidth+5)+5,(j/4)*(viewWidth+5)+groupHeaderView.frameBottom,viewWidth,viewWidth)];
                appView.delegate = self;
                appView.item = item;
                [self.baseScrollView addSubview:appView];
                if(j == otherAppDataArr.count - 1){
                    if (i == array.count - 1) {
                        _otherAppViewHeight = appView.frameBottom;
                        [self.baseScrollView addSubview:self.otherFooterView];// 添加底部视图
                    } else {
                        UIView *footerLine = [[UIView alloc] initWithFrame:CGRectMake(0, appView.frameBottom, WIDTH_SCREEN, 1)];
                        footerLine.backgroundColor = DEFAULT_BACKGROUND_COLOR;
                        [self.baseScrollView addSubview:footerLine];// 添加底部视图
                        lastGroupView = footerLine;
                    }
                }
            }
        }
    }
}

#pragma mark - 长按挪动方法
#pragma mark 长安触发事件
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)sender {
    AppView *appView = (AppView *)sender.view;
    [appView.superview bringSubviewToFront:appView];// 把当前选中视图挪到最前方
    if (sender.state == UIGestureRecognizerStateBegan) {
        _startPoint = [sender locationInView:sender.view];
        _beginPos = appView.tag;
        _viewPoint = appView.center;
        [UIView animateWithDuration:0.2 animations:^{
            appView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
            appView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            appView.alpha = 1.0;
        }];
    } else if (sender.state == UIGestureRecognizerStateChanged){
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX = newPoint.x - _startPoint.x;
        CGFloat deltaY = newPoint.y - _startPoint.y;
        appView.center = CGPointMake(appView.center.x + deltaX, appView.center.y + deltaY);
        NSInteger fromIndex = appView.tag;
        
        NSInteger toIndex = [self judgeMoveByButtonPoint:appView.center moveButton:appView];
        
        if (toIndex < 0) {
            return;
        } else {
            appView.tag = toIndex;
            // 向后移动
            if (fromIndex - toIndex < 0) {
                for (NSInteger i = fromIndex; i < toIndex; i ++) {
                    AppView *nextAppView = _mineAppViewArray[i+1];
                    // 改变按钮中心点的位置
                    CGPoint temp = nextAppView.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        nextAppView.center = _viewPoint;
                    }];
                    _viewPoint = temp;
                    // 交换tag值
                    nextAppView.tag = i;
                    
                }
                [self sortArray];
            } else if (fromIndex - toIndex > 0) {
                // 向前移动
                for (NSInteger i = fromIndex; i > toIndex; i --) {
                    AppView *beforAppView = _mineAppViewArray[i - 1];
                    CGPoint temp = beforAppView.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        beforAppView.center = _viewPoint;
                    }];
                    _viewPoint = temp;
                    beforAppView.tag = i;
                }
                [self sortArray];
            }
        }
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            appView.backgroundColor = [UIColor whiteColor];
            appView.transform = CGAffineTransformIdentity;
            appView.alpha = 1.0f;
            appView.center = _viewPoint;
        }];
    }
}
#pragma mark 对数组排序
- (void)sortArray {
    
    _adjustStatus = YES;    // 设置调整标志
    
    // 对已改变按钮的数组进行排序
    [_mineAppViewArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AppView *temp1 = (AppView *)obj1;
        AppView *temp2 = (AppView *)obj2;
        return temp1.tag > temp2.tag;    //将tag值大的按钮向后移
    }];
}
#pragma mark 移动判断方法
- (NSInteger)judgeMoveByButtonPoint:(CGPoint)point moveButton:(AppView *)view {
    /**
     * 判断移动按钮的中心点是否包含了所在按钮的中心点如果是将i返回
     */
    for (NSInteger i = 0; i < _mineAppViewArray.count; i++) {
        AppView *appView = _mineAppViewArray[i];
        if (!view || appView != view) {
            if (CGRectContainsPoint(appView.frame, point)) {
                return i;
            }
        }
    }
    return -1;
}

#pragma mark - 各组件懒加载Getter方法
#pragma mark 顶部视图
- (AppTopView *)appTopView {
    if(!_appTopView){
        _appTopView = [[AppTopView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 160)];
        _appTopView.delegate = self;
    }
    return _appTopView;
}
#pragma mark 初始化基本的回弹UIScrollView视图
- (BaseScrollView *)baseScrollView {
    if(!_baseScrollView){
        _baseScrollView = [[BaseScrollView alloc] initWithFrame:CGRectMake(0, self.appTopView.frameBottom, WIDTH_SCREEN, HEIGHT_SCREEN - self.appTopView.frameBottom - HEIGHT_TABBAR)];
        _baseScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _baseScrollView;
}
#pragma mark 下拉显示logo视图
- (UIView *)pullHiddenView {
    if(!_pullHiddenView){
        _pullHiddenView = [[UIView alloc] initWithFrame:CGRectMake(0, -HEIGHT_SCREEN, WIDTH_SCREEN, HEIGHT_SCREEN)];
        _pullHiddenView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_pullHiddenView.frameWidth/2-83, _pullHiddenView.frameHeight-90, 166, 45)];
        imageView.image = [UIImage imageNamed:@"app_common_pull_logo"];
        [_pullHiddenView addSubview:imageView];
    }
    return _pullHiddenView;
}
#pragma mark 我的应用分组头视图
- (AppHeaderView *)mineHeaderView {
    if(!_mineHeaderView){
        _mineHeaderView = [[AppHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 30.0f)];
        _mineHeaderView.title = @"我的应用";
    }
    return _mineHeaderView;
}
#pragma mark - 我的应用分组底部视图
- (UIView *)mineFooterView {
    if(!_mineFooterView){
        _mineFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 1)];
        _mineFooterView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    }
    _mineFooterView.originY = _mineAppViewHeight;
    return _mineFooterView;
}
#pragma mark 其他应用分组头视图
- (AppHeaderView *)otherHeaderView {
    if(!_otherHeaderView){
        _otherHeaderView = [[AppHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 30.0f)];
        _otherHeaderView.title = @"更多应用";
    }
    _otherHeaderView.originY = self.mineFooterView.frameBottom;
    return _otherHeaderView;
}
#pragma mark 其他应用分组底部视图
- (AppFooterView *)otherFooterView {
    if(!_otherFooterView){
        _otherFooterView = [[AppFooterView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 20.0f)];
    }
    _otherFooterView.originY = _otherAppViewHeight;
    return _otherFooterView;
}

#pragma mark - 各视图点击代理方法
#pragma mark 应用顶部视图点击代理方法AppTopViewDelegate
- (void)appTopViewBtnClick:(UIButton *)sender {
    
    UIViewController *viewController= nil;
    NSString *url = nil;
    
    if(sender.tag == 1){
        viewController = [[NSClassFromString(@"AppSearchViewController") class] new];
    }
    if(sender.tag == 2){
        self.reload = YES;
        viewController = [[NSClassFromString(@"AppEditViewController") class] new];
    }
    if(sender.tag == 21){   // 通知公告
        url = [NSString stringWithFormat:@"%@public/notice/10/1", SERVER_URL];
    }
    if(sender.tag == 22){   // 局通讯录
        url = [NSString stringWithFormat:@"%@litter/initLitter", SERVER_URL];
    }
    if(sender.tag == 23){   // 税务地图
        viewController = [[NSClassFromString(@"MapListViewController") class] new];
        viewController.jz_navigationBarTintColor = DEFAULT_BLUE_COLOR;
    }
    if(sender.tag == 24){   // 常见问题
        url = [NSString stringWithFormat:@"%@taxnews/public/comProblemIOS.htm", SERVER_URL];
    }
    
    if(viewController == nil && url != nil){
        viewController = [[BaseWebViewController alloc] initWithURL:url];
        viewController.jz_navigationBarTintColor = DEFAULT_BLUE_COLOR;
        viewController.title = sender.titleLabel.text;
    }
    
    if(viewController != nil){
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
#pragma mark 应用模块视图点击代理方法AppViewDelegate
- (void)appViewClick:(AppView *)appView{
    
    UIViewController *viewController = nil;
    
    NSString *url = appView.item.url;
    if(url == nil || url.length <= 0){
        int level = [appView.item.level intValue]+1;
        viewController = [[AppSubViewController alloc] initWithPno:appView.item.no level:[NSString stringWithFormat:@"%d", level]];
    }else{
        viewController = [[BaseWebViewController alloc] initWithURL:url];
    }
    
    viewController.title = appView.item.title; // 设置标题
    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark - 自定义排序保存方法
- (void)editMineAppDataSort{
    // 获取缓存中的最新数据
    NSMutableDictionary *appData = [[AppUtil sharedAppUtil] loadAppData];
    NSMutableArray *mineData = [[NSMutableArray alloc] init];
    
    // 我的应用数据
    for(AppView *appView in self.mineAppViewArray){
        NSString *appno = appView.item.no;
        NSString *appname = appView.item.title;
        NSString *appimage = appView.item.webImg;
        NSString *appurl = appView.item.url;
        NSString *userappsort = [NSString stringWithFormat:@"%d", (int)appView.tag];
        NSString *isnewapp = appView.item.isNewApp ? @"Y" : @"N";
        
        NSDictionary *mineDict = [NSDictionary dictionaryWithObjectsAndKeys: appno, @"appno", appname, @"appname", appimage, @"appimage", appurl, @"appurl", userappsort, @"userappsort", @"1", @"apptype", isnewapp, @"isnewapp", nil];
        [mineData addObject:mineDict];
    }
    
    [appData setValue:mineData forKey:@"mineData"];
    // 保存本地
    [[AppUtil sharedAppUtil] writeAppData:appData];
    
    [[AppUtil sharedAppUtil] saveCustomData:mineData success:^(id responseObject) {
        _adjustStatus = NO; // 保存成功后记录
    } failure:^(NSString *error) {
        
    } invalid:^(NSString *msg) {
        
    }];
}
@end
