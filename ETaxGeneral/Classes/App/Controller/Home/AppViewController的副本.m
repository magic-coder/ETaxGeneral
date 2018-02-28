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
#import "AppPullHidenView.h"
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

@property (nonatomic, assign) CGPoint viewPoint;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSInteger beginPos;
@property (nonatomic, assign) NSInteger endPos;

@property (nonatomic, assign) CGFloat mineViewHeight;
@property (nonatomic, assign) CGFloat otherViewHeight;

@property (nonatomic, strong) AppTopView *topView;
@property (nonatomic, strong) AppPullHidenView *pullHidenView;
@property (nonatomic, strong) BaseScrollView *baseScrollView;

@property (nonatomic, strong) AppHeaderView *mineHeaderView;
@property (nonatomic, strong) AppHeaderView *otherHeaderView;
@property (nonatomic, strong) UIView *mineFooterView;
@property (nonatomic, strong) AppFooterView *otherFooterView;

@property (nonatomic, strong) NSMutableArray *mineAppData;
@property (nonatomic, strong) NSArray *allAppData;
@property (nonatomic, strong) NSMutableArray *otherAppData;

@property (nonatomic, strong) NSMutableArray *viewArray;

@property (nonatomic, assign) BOOL adjustStatus;

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.baseScrollView];
    [self.baseScrollView addSubview:self.pullHidenView];
    [self.baseScrollView addSubview:self.mineHeaderView];
    
    [self.view bringSubviewToFront:self.topView];// 设置视图层级为最上层
    [self.view sendSubviewToBack:self.baseScrollView];// 设置视图层级为最底下
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUI{
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;// 设置顶部状态栏字体为白色
    
    _adjustStatus = NO;// 初始化调整状态值
    
    if(IS_LOGIN){
        [self initializeData];
    }else{
        SHOW_LOGIN_VIEW
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];// 设置导航栏itemBar字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };// 设置导航栏title标题字体颜色
    [self.navigationController.navigationBar setBarTintColor:DEFAULT_BLUE_COLOR];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(_adjustStatus)
        [self editDataSort];
    
}

#pragma mark - 初始化数据
- (void)initializeData {
    NSMutableDictionary *appDict = [[AppUtil sharedAppUtil] loadAppData];
    if(appDict){
        [self handleData:appDict];
    }else{
        [[AppUtil sharedAppUtil] initAppDataBlock:^(NSMutableDictionary *dataDict) {
            [self handleData:dataDict];
        } failed:^(NSString *error) {
            [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
        }];
    }
}

#pragma mark - 处理获取到的数据
- (void)handleData:(NSMutableDictionary *)data{
    _mineAppData = [data objectForKey:@"mineData"];
    _otherAppData = [data objectForKey:@"otherData"];
    _allAppData = [data objectForKey:@"allData"];
    
    [self initAppBorderView];
    [self initAppViewData:_otherAppData type:AppViewTypeOther];
    
    [self.baseScrollView setContentSize:CGSizeMake(WIDTH_SCREEN, _otherViewHeight+HEIGHT_STATUS+15)];
}

#pragma mark - 添加应用图标底层虚线边框
- (void)initAppBorderView {
    int itemWidth = ((WIDTH_SCREEN - 50) / 4);
    
    for (int i = 0; i < _mineAppData.count; i++) {
        CGRect frame = CGRectMake((i%4)*(itemWidth+10)+10,(i/4)*(itemWidth+10)+self.mineHeaderView.frameBottom+10,itemWidth-10,itemWidth-10);
        frame = CGRectInset(frame, 1, 1);
        AppBorderView *appBorderView = [[AppBorderView alloc] initWithFrame:frame];
        [self.baseScrollView addSubview:appBorderView];
    }
    [self initAppViewData:_mineAppData type:AppViewTypeMine];
}

#pragma mark - 初始化创建应用模块视图
- (void)initAppViewData:(NSArray *)data type:(AppViewType)type{
    int viewWidth = ((WIDTH_SCREEN - 25) / 4);
    
    for (int i = 0; i < data.count; i++) {
        AppModelItem *item = [AppModelItem createWithDictionary:data[i]];
        AppView *appView = [[AppView alloc] init];
        appView.delegate = self;
        appView.item = item;
        
        if(type == AppViewTypeMine){
            appView.tag = i;
            appView.frame = CGRectMake((i%4)*(viewWidth+5)+5,(i/4)*(viewWidth+5)+self.mineHeaderView.frameBottom,viewWidth,viewWidth);
            
            if(i == data.count-1){
                _mineViewHeight = appView.frameBottom;
                [self.baseScrollView addSubview:self.mineFooterView];// 添加底部视图
            }
                
            // 添加长按手势
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
            [appView addGestureRecognizer:longGesture];
            
            [self.baseScrollView addSubview:appView];
            [self.viewArray addObject:appView];
        }
        
        if(type == AppViewTypeOther){
            [self.baseScrollView addSubview:self.otherHeaderView];// 添加分组头部视图
            appView.frame = CGRectMake((i%4)*(viewWidth+5)+5,(i/4)*(viewWidth+5)+self.otherHeaderView.frameBottom,viewWidth,viewWidth);
            
            if(i == data.count-1){
                _otherViewHeight = appView.frameBottom;
                [self.baseScrollView addSubview:self.otherFooterView];// 添加底部视图
            }
            
            [self.baseScrollView addSubview:appView];
        }
    }
        
}

#pragma mark - 长按挪动方法
#pragma mark 长安触发事件
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)sender {
    AppView *appView = (AppView *)sender.view;
    [appView.superview bringSubviewToFront:appView];// 把当前选中视图挪到最前方
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        _startPoint = [sender locationInView:appView];
        _beginPos = appView.tag;
        _viewPoint = appView.center;
        NSLog(@"appView = %@",appView);
        NSLog(@"appView.tag = %lu",appView.tag);
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
                    AppView *nextAppView = _viewArray[i+1];
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
                    AppView *beforAppView = _viewArray[i - 1];
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
    
    _adjustStatus = YES;
    
    // 对已改变按钮的数组进行排序
    [_viewArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
    for (NSInteger i = 0; i < _mineAppData.count; i++) {
        AppView *appView = _viewArray[i];
        if (!view || appView != view) {
            if (CGRectContainsPoint(appView.frame, point)) {
                return i;
            }
        }
    }
    return -1;
}

#pragma mark - Getter方法
- (NSMutableArray *)viewArray {
    if(!_viewArray){
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}
#pragma mark 初始化顶部视图
- (AppTopView *)topView {
    if(!_topView){
        _topView = [[AppTopView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_STATUS+136)];
        _topView.delegate = self;
    }
    return _topView;
}

- (AppPullHidenView *)pullHidenView {
    if(!_pullHidenView){
        _pullHidenView = [[AppPullHidenView alloc] initWithFrame:CGRectMake(0, -HEIGHT_SCREEN, WIDTH_SCREEN, HEIGHT_SCREEN)];
    }
    return _pullHidenView;
}

#pragma mark 初始化基本的回弹UIScrollView视图
- (BaseScrollView *)baseScrollView {
    if(!_baseScrollView){
        _baseScrollView = [[BaseScrollView alloc] initWithFrame:CGRectMake(0,self.topView.frameBottom, WIDTH_SCREEN, HEIGHT_SCREEN - self.topView.frameBottom - HEIGHT_TABBAR)];
        _baseScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _baseScrollView;
}

#pragma mark 初始化我的应用头部视图
- (AppHeaderView *)mineHeaderView {
    if(!_mineHeaderView){
        _mineHeaderView = [[AppHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 30)];
        _mineHeaderView.title = @"我的应用";
    }
    return _mineHeaderView;
}

#pragma mark 初始化我的应用底部视图
- (UIView *)mineFooterView {
    if(!_mineFooterView){
        _mineFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, _mineViewHeight, WIDTH_SCREEN, 1)];
        _mineFooterView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    }
    return _mineFooterView;
}

#pragma mark 初始化其他应用头部视图
- (AppHeaderView *)otherHeaderView {
    if(!_otherHeaderView){
        _otherHeaderView = [[AppHeaderView alloc] initWithFrame:CGRectMake(0, self.mineFooterView.frameBottom, WIDTH_SCREEN, 30)];
        _otherHeaderView.title = @"更多应用";
    }
    return _otherHeaderView;
}

#pragma mark 初始化其他应用底部视图
- (AppFooterView *)otherFooterView {
    if(!_otherFooterView){
        _otherFooterView = [[AppFooterView alloc] initWithFrame:CGRectMake(0, _otherViewHeight, WIDTH_SCREEN, 1)];
    }
    return _otherFooterView;
}

#pragma mark - <AppTopViewDelegate>应用顶部视图点击代理方法
- (void)appTopViewBtnClick:(UIButton *)sender {
    if(sender.tag == 1){
        [self.navigationController pushViewController:[[NSClassFromString(@"AppSearchViewController") class] new] animated:YES];
    }
    if(sender.tag == 2){
        [self.navigationController pushViewController:[[NSClassFromString(@"AppEditViewController") alloc] init] animated:YES];
    }
}

#pragma mark - <AppViewDelegate>应用模块视图点击代理方法
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

#pragma mark - 排序数据保存
- (void)editDataSort{
    NSDictionary *appData = [[AppUtil sharedAppUtil] loadAppData];
    
    NSMutableArray *mineData = [[NSMutableArray alloc] init];
    
    // 我的应用数据
    for(AppView *appView in self.viewArray){
        NSString *appno = appView.item.no;
        NSString *appname = appView.item.title;
        NSString *appimage = appView.item.webImg;
        NSString *appurl = appView.item.url;
        NSString *userappsort = [NSString stringWithFormat:@"%d", (int)appView.tag];
        NSString *isnewapp = appView.item.isNewApp ? @"Y" : @"N";
        
        NSDictionary *mineDict = [NSDictionary dictionaryWithObjectsAndKeys: appno, @"appno", appname, @"appname", appimage, @"appimage", appurl, @"appurl", userappsort, @"userappsort", @"1", @"apptype", isnewapp, @"isnewapp", nil];
        [mineData addObject:mineDict];
    }
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:mineData, @"mineData", [appData objectForKey:@"otherData"], @"otherData", [appData objectForKey:@"allData"], @"allData", nil];
    
    [[AppUtil sharedAppUtil] writeAppData:dataDict];
}

@end
