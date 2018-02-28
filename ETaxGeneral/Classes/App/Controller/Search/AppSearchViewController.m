/************************************************************
 Class    : AppSearchViewController.m
 Describe : 应用搜索界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-23
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppSearchViewController.h"
#import "AppSubViewController.h"
#import "AppSearchTableView.h"
#import "AppSearchViewCell.h"
#import "AppModel.h"
#import "AppUtil.h"


@interface AppSearchViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, AppSearchTableViewDelegate>

@property (nonatomic, strong) AppSearchTableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) TTTAttributedLabel *hintLabel;    // 搜索提示信息
@property (nonatomic, strong) UIFont *hintFont;                 // 搜索提示字体

@property (nonatomic, strong) UITextField *searchTextField;     // 搜索输入框
@property (nonatomic, strong) UIView *searchLine;               // 顶部搜索视图底部线条
@property (nonatomic, strong) UIButton *cancelBtn;              // 取消按钮
@property (nonatomic, strong) NSMutableArray *results;          // 数据筛选结果

@end

@implementation AppSearchViewController

static NSString * const reuseIdentifier = @"appSubCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"应用搜索";
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _hintFont = [UIFont systemFontOfSize:14.0f];
    
    _tableView = [[AppSearchTableView alloc] initWithFrame:CGRectMake(0, HEIGHT_STATUS + HEIGHT_NAVBAR - 0.5f, WIDTH_SCREEN, HEIGHT_SCREEN - HEIGHT_NAVBAR - HEIGHT_STATUS + 0.5f) style:UITableViewStylePlain];
    _tableView.touchDelegate = self;
    _tableView.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[AppSearchViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [_tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    // 防止UITableView顶部空隙
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, HEIGHT_STATUS+8, WIDTH_SCREEN - 15 - 60, 28)];
    _searchTextField.layer.cornerRadius = 5;
    _searchTextField.layer.borderWidth = .5;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.layer.borderColor = DEFAULT_LINE_GRAY_COLOR.CGColor;
    _searchTextField.font = [UIFont systemFontOfSize:15.0f];
    _searchTextField.placeholder = @"请输入应用名称";
    _searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(_searchTextField.frame), CGRectGetHeight(_searchTextField.frame))];
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 22, 22)];
    imgSearch.image = [UIImage imageNamed:@"app_common_search"];
    [_searchTextField.leftView addSubview:imgSearch];
    [_searchTextField addTarget:self action:@selector(searchApp:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_searchTextField];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBtn.frame = CGRectMake(15 + (WIDTH_SCREEN - 15 - 60), HEIGHT_STATUS+8, 60, 28);
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
    
    _searchLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT_STATUS + HEIGHT_NAVBAR-0.5f, WIDTH_SCREEN, 0.5f)];
    _searchLine.backgroundColor = DEFAULT_LINE_GRAY_COLOR;
    [self.view addSubview:_searchLine];
    
    [_searchTextField becomeFirstResponder];    // 搜索输入框获取焦点
    
    _data = [[NSMutableArray alloc] init];
    _data = [[AppUtil sharedAppUtil] loadSearchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 设置顶部状态栏字体为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_results.count <= 0){
        NSString *keyWords = _searchTextField.text;
        NSString *textStr = @"请输入应用名称/首字母，尽情搜索吧！😊";
        if(keyWords.length>0)
            textStr = [NSString stringWithFormat:@"找不到任何与“%@”相匹配的应用", keyWords];
        float textHeight = [[BaseHandleUtil sharedBaseHandleUtil] calculateHeightWithText:textStr width:WIDTH_SCREEN-20 font:_hintFont];
        float hintLabelY = 120.0f;
        self.hintLabel.frame = CGRectMake(10, hintLabelY, WIDTH_SCREEN-20, textHeight);
        if([textStr rangeOfString:@"找不到任何与"].location != NSNotFound && [textStr rangeOfString:@"相匹配的应用"].location != NSNotFound){
            [self.hintLabel setText:textStr afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                // 设置可点击文字的范围
                //NSRange linkRange = [[mutableAttributedString string] rangeOfString:@"找不到" options:NSCaseInsensitiveSearch];
                NSRange linkRange = NSMakeRange(6, textStr.length-12);
                // 设置可点击文字的颜色
                [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)DEFAULT_RED_COLOR range:linkRange];
                
                return mutableAttributedString;
            }];
        }else{
            self.hintLabel.text = textStr;
        }
        
        [self.emptyView addSubview:self.hintLabel];
        
        [self.tableView addSubview:self.emptyView];
    }else{
        [self.emptyView removeFromSuperview];
    }
    
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    AppModelItem *item = [_results objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setItem:item];
    indexPath.row == 0 ? [cell setTopLineStyle:AppSearchViewCellLineStyleFill] : [cell setTopLineStyle:AppSearchViewCellLineStyleNone];
    indexPath.row == _results.count - 1 ? [cell setBottomLineStyle:AppSearchViewCellLineStyleFill] : [cell setBottomLineStyle:AppSearchViewCellLineStyleDefault];
    
    // 关键词高亮
    NSString *searchStr = [[_searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    if(searchStr){
        NSRange range;
        NSArray *keyWordsArray = [item.keyWords componentsSeparatedByString:@" "];
        for(NSString *keyWords in keyWordsArray){
            range = [keyWords rangeOfString:searchStr];
            if(range.length > 0){
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:item.title];
                //NSRange range = [model.title rangeOfString:_searchTextField.text];
                [attr addAttribute:NSForegroundColorAttributeName value:DEFAULT_BLUE_COLOR range:range];
                cell.titleLabel.attributedText = attr;
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark 返回行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63.0f;
}

#pragma mark 点击行触发点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    // 获取当前点击的cell
    AppSearchViewCell *cell = (AppSearchViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *viewController = nil;
    
    NSString *url = cell.item.url;
    if(url == nil || url.length <= 0){
        int level = [cell.item.level intValue]+1;
        viewController = [[AppSubViewController alloc] initWithPno:cell.item.no level:[NSString stringWithFormat:@"%d", level]];
    }else{
        viewController = [[BaseWebViewController alloc] initWithURL:url];
    }
    viewController.jz_navigationBarTintColor = DEFAULT_BLUE_COLOR;
    viewController.title = cell.item.title; // 设置标题
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - <AppSearchTableViewDelegate> Touch代理方法
- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

// 查询方法
- (void)searchApp:(UITextField *)textField{
    NSString *searchString = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    //NSPredicate 谓词
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF.keyWords CONTAINS [cd] %@", searchString];
    if (_results != nil) {
        [_results removeAllObjects];
    }
    
    //过滤数据
    _results = [NSMutableArray arrayWithArray:[_data filteredArrayUsingPredicate:preicate]];
    //刷新表格
    [_tableView reloadData];
}

// 取消方法
- (void)cancelSearch:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

- (UIView *)emptyView {
    if(!_emptyView){
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN)];
        _emptyView.backgroundColor = [UIColor whiteColor];
        
        //UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_SCREEN/2-25, 40, 50, 50)];
        UIImageView *searchImageView = [UIImageView new];
        [searchImageView setImage:[UIImage imageNamed:@"app_common_search_hint"]];
        [_emptyView addSubview:searchImageView];
        
        float top = 40.0f;
        CGSize size = CGSizeMake(50, 50);
        
        [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView);
            make.top.equalTo(_emptyView).with.offset(top);
            make.size.mas_equalTo(size);
        }];
        
    }
    return _emptyView;
}

- (TTTAttributedLabel *)hintLabel{
    if(!_hintLabel){
        _hintLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _hintLabel.numberOfLines = 0;
        _hintLabel.font = _hintFont;
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.textColor = [UIColor grayColor];
        _hintLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;// 对齐方式
    }
    return _hintLabel;
}

@end
