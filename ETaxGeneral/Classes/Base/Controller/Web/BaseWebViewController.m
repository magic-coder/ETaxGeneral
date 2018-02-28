/************************************************************
 Class    : BaseWebViewController.m
 Describe : 基本的WebView视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-17
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseWebViewController.h"

@interface BaseWebViewController () <UIWebViewDelegate, NSURLConnectionDataDelegate, UIGestureRecognizerDelegate, YBPopupMenuDelegate>

@property (nonatomic, strong) UIView *imagesViewBG;         // 等待界面视图
@property (nonatomic, strong) UIWebView *webViewBG;         // 加载等待GIF图

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) BOOL authenticated;           // 是否是自签名授权

@property (nonatomic, strong) UIBarButtonItem *backItem;    // 导航栏左侧 返回按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;   // 导航栏左侧 关闭按钮
@property (nonatomic, strong) UIBarButtonItem *moreItem;   // 导航栏右侧 更多按钮

// 加载时长计时器
@property (nonatomic, strong) NSTimer *loadTimer;
@property (nonatomic, assign) int loadTimeCount;

@end

@implementation BaseWebViewController

#pragma mark - 初始化创建方法
- (instancetype)initWithURL:(NSString *)url{
    if (self = [super init]) {
        _url = [NSURL URLWithString:url];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;  // 滑动手势返回方法
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    self.navigationItem.leftBarButtonItem = self.backItem;  // 自定义导航栏左侧按钮
    // 自定义导航栏右侧按钮
    UIBarButtonItem *moreButtonItem  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigation_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAction:)];
    self.navigationItem.rightBarButtonItem = moreButtonItem;
    
    [self.view addSubview:self.webView];
    [self.webView loadRequest:self.request];

    [self showLoadingView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图已经销毁执行的方法
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self loadTimerDestroy];
    self.webView.delegate = nil;
}

#pragma mark - 各组件对应懒加载方法
#pragma mark webView 主视图
- (UIWebView *)webView {
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frameWidth, self.view.frameHeight)];
        _webView.backgroundColor = [UIColor whiteColor];
        //_webView.scalesPageToFit = YES;// 自适应
        _webView.opaque = NO;           // 去掉底部黑色部分
        _webView.delegate = self;
    }
    return _webView;
}
#pragma mark 请求 request 对象
- (NSMutableURLRequest *)request {
    if(!_request){
        _request = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
        // 对request中携带cookie进行请求
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSDictionary *cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [_request setHTTPShouldHandleCookies:YES];
        [_request setAllHTTPHeaderFields:cookieHeader];
    }
    return _request;
}
#pragma mark 导航栏左侧返回按钮
- (UIBarButtonItem *)backItem{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //这是一张“<”的图片，可以让美工给切一张
        UIImage *image = [UIImage imageNamed:@"navigation_back_arrow"];
        UIImage *imageHL = [UIImage imageNamed:@"navigation_back_arrowHL"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:imageHL forState:UIControlStateHighlighted];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
        //[btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
        //字体的多少为btn的大小
        [btn sizeToFit];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        btn.frame = CGRectMake(0, 0, 50, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}
#pragma mark 导航栏左侧关闭按钮
- (UIBarButtonItem *)closeItem{
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeNative)];
        _closeItem.tintColor = [UIColor whiteColor];
    }
    return _closeItem;
}
#pragma mark 导航栏右侧更多按钮
- (void)moreAction:(UIBarButtonItem *)sender {
    if ([self.webView.request.URL.absoluteString rangeOfString:@"app/evaluation/index"].location != NSNotFound) {
        [YBPopupMenu showPopupMenuWithTitles:@[@"刷新"] icons:@[@"common_web_refresh"] delegate:self];
    }else{
        [YBPopupMenu showPopupMenuWithTitles:@[@"刷新", @"系统评价"] icons:@[@"common_web_refresh", @"common_web_evaluate"] delegate:self];
    }
}

#pragma mark - 更多按钮气泡菜单点击代理方法
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu {
    if(index == 0){
        [self.webView reload];
    }
    if(index == 1){
        self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@app/evaluation/index", SERVER_URL]]];
        [self.webView loadRequest:self.request];
    }
}

#pragma mark - 自定义组件方法
#pragma mark 导航栏返回按钮的方法
- (void)backNative{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        //self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        [self closeNative];
    }
}
#pragma mark 导航栏关闭按钮点击方法
- (void)closeNative {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate 代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    DLog(@"%@", request.URL.absoluteString);
    // 如果响应的地址是指定域名，则允许跳转
    if ([request.URL.absoluteString rangeOfString:@"account/initLogin"].location != NSNotFound) {
        // 进行token登录
        [[LoginUtil sharedLoginUtil] loginWithTokenSuccess:^{
            [self.webView loadRequest:self.request];
        } failure:^(NSString *error) {
        } invalid:^(NSString *msg) {
            SHOW_RELOGIN_VIEW
        }];
    }else{
        //判断是不是https
        NSString *scheme = [[request URL] scheme];
        if ([scheme isEqualToString:@"https"]) {
            if (!_authenticated) {
                _authenticated = NO;
                _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
                [_connection start];
                return NO;
            }
        }
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self loadTimerDestroy];    // 销毁timer
    [_imagesViewBG removeFromSuperview];
    
    // 若视图控制器没有传入标题，则获取web页面标题进行设置
    if(self.title == nil || [self.title isEqualToString:@""]){
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    }
}

#pragma mark - NSURLConnectionDelegate 代理方法
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0){
        _authenticated = YES;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else{
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _authenticated = YES;
    /*
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    [[session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%s",__FUNCTION__);
        NSLog(@"RESPONSE:%@",response);
        NSLog(@"ERROR:%@",error);
    
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString:%@",dataString);
    
        [self loadHTMLString:dataString baseURL:nil];
    }] resume];
     */
    [self.webView loadRequest:self.request];
    [_connection cancel];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showLoadingFailedView];   // 显示加载失败提示界面
}

#pragma mark - 加载时长计时器方法
#pragma mark 加载计时器开始
- (void)loadTimerCallback{
    _loadTimeCount++;
    if(_loadTimeCount == 100){
        [self showLoadingFailedView];// 显示错误页面
    }
}
#pragma mark 销毁加载计时器
- (void)loadTimerDestroy{
    if(_loadTimer.isValid){
        [_loadTimer invalidate];
        _loadTimer = nil;
    }
}

#pragma mark - 设置加载等待动画界面
- (void)showLoadingView{
    
    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(loadTimerCallback) userInfo:nil repeats:YES];
    
    // 添加等待背景图
    _imagesViewBG = [[UIView alloc] initWithFrame:self.view.frame];
    _imagesViewBG.backgroundColor = [UIColor whiteColor];
    _imagesViewBG.userInteractionEnabled = NO;
    
    // 添加加载等待图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"common_loading_wait" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:filePath];
    _webViewBG = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.frameWidth/2-160, self.view.frameHeight/2-150, 320, 200)];
    NSURL *baseUrl = nil;
    [_webViewBG loadData:gifData MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:baseUrl];
    _webViewBG.userInteractionEnabled = NO;
    [_imagesViewBG addSubview:_webViewBG];
    
    [self.view addSubview:_imagesViewBG];
}

#pragma mark - 设置加载失败界面
- (void)showLoadingFailedView{
    [self loadTimerDestroy];
    
    [self.webView stopLoading];// 停止加载
    // 移除现有组件
    [_webViewBG removeFromSuperview];
    
    // 重置背景颜色
    _imagesViewBG.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    // 加载失败图片
    UIImageView *imagesView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frameWidth/2-30, 100, 60, 60)];
    imagesView.image = [UIImage imageNamed:@"common_loading_failed"];
    [_imagesViewBG addSubview:imagesView];
    
    // 提示文字
    UILabel *failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imagesView.frame)+10, self.view.frameWidth, 40)];
    failedLabel.textAlignment = NSTextAlignmentCenter;
    failedLabel.textColor = [UIColor lightGrayColor];
    failedLabel.font = [UIFont systemFontOfSize:15.0f];
    failedLabel.numberOfLines = 0;
    failedLabel.text = @"呃，页面加载失败了！\n 请检查网络是否正常，并退出后重新尝试！";
    
    [_imagesViewBG addSubview:failedLabel];
    
    [self.view addSubview:_imagesViewBG];
    
}

@end
