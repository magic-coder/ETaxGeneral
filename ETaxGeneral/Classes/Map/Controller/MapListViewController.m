/************************************************************
 Class    : MapListViewController.m
 Describe : 地图机构列表（tree结构）
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MapListViewController.h"
#import "MapViewController.h"
#import "MapListViewCell.h"
#import "MapListModel.h"
#import "MapListUtil.h"

@interface MapListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;     // 传递过来已经组织好的数据（全量数据）
@property (nonatomic, strong) NSMutableArray *tempData; // 用于存储数据源（部分数据）

@end

@implementation MapListViewController

static NSString * const reuseIdentifier = @"reuseIdentifierGroup";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    
    self.title = @"税务地图";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    //self.tableView.showsVerticalScrollIndicator = NO;   // 去掉右侧滚动条
    // 注册cell
    [self.tableView registerClass:[MapListViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];// Table分组头视图不显示
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    // 添加导航栏右侧按钮
    UIBarButtonItem *refreshButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    
    // 初始化数据
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 刷新数据方法
- (void)refreshAction:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeEvent];
    [[MapListUtil sharedMapListUtil] initMapDataSuccess:^(NSMutableArray *dataArray) {
        sender.enabled = YES;
        [MBProgressHUD hiddenHUDView:self.view];
        _data = dataArray;
        _tempData = [self createTempData:_data];
        
        [self.tableView reloadData];
    } failure:^(NSString *error) {
        sender.enabled = YES;
        [MBProgressHUD hiddenHUDView:self.view];
        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
    } invalid:^(NSString *msg) {
        sender.enabled = YES;
        [MBProgressHUD hiddenHUDView:self.view];
        SHOW_LOGIN_VIEW
    }];
}

// 初始化数据
-(void)initData{
    _data = [[MapListUtil sharedMapListUtil] loadMapData];
    if(_data.count > 0){
        _tempData = [self createTempData:_data];
    }else{
        [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
        [[MapListUtil sharedMapListUtil] initMapDataSuccess:^(NSMutableArray *dataArray) {
            [MBProgressHUD hiddenHUDView:self.view];
            _data = dataArray;
            _tempData = [self createTempData:_data];
            
            [self.tableView reloadData];
        } failure:^(NSString *error) {
            [MBProgressHUD hiddenHUDView:self.view];
            [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
        } invalid:^(NSString *msg) {
            [MBProgressHUD hiddenHUDView:self.view];
            SHOW_LOGIN_VIEW
        }];
    }
}

// 处理展示的数据
-(NSMutableArray *)createTempData : (NSArray *)data{
    NSMutableArray *tempArray = [NSMutableArray array];
    for(MapListModel *model in data){
        if (model.isExpand) {
            [tempArray addObject:model];
        }
    }
    return tempArray;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tempData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    MapListModel *model = [_tempData objectAtIndex:indexPath.row];
    cell.model = model; // 为cell中的model设置值
    // cell有缩进的方法
    //cell.indentationLevel = model.level;    // 缩进级别
    //cell.indentationWidth = 30.0f;  // 每个缩进级别的距离
    
    return cell;
}

#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    //先修改数据源
    MapListModel *parentModel = [_tempData objectAtIndex:indexPath.row];
    NSUInteger startPosition = indexPath.row+1;
    NSUInteger endPosition = startPosition;
    BOOL isExpand = NO;
    for (int i=0; i < _data.count; i++) {
        MapListModel *model = [_data objectAtIndex:i];
        if ([model.parentCode isEqualToString:parentModel.nodeCode]) {
            model.isExpand = !model.isExpand;
            if (model.isExpand) {
                [_tempData insertObject:model atIndex:endPosition];
                isExpand = YES;
                endPosition++;
            }else{
                isExpand = NO;
                endPosition = [self removeAllMapListModelsAtParentMapListModel:parentModel];
                break;
            }
        }
    }
    
    //获得需要修正的indexPath
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=startPosition; i < endPosition; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    //插入或者删除相关节点
    if (isExpand) {
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // 点击cell跳转到地图页面处理方法
    if(startPosition == endPosition){
        if(!parentModel.latitude && !parentModel.longitude){
            DLog(@"没有坐标点，不可以跳转");
            return;
        }else{
            // 开始进行地图界面跳转
            MapViewController *mapVC = [[MapViewController alloc] init];
            mapVC.model = parentModel;
            [self.navigationController pushViewController:mapVC animated:YES];
        }
    }
}

/**
 *  删除该父节点下的所有子节点（包括孙子节点）
 *
 *  @param parentModel 父节点
 *
 *  @return 该父节点下一个相邻的统一级别的节点的位置
 */
-(NSUInteger)removeAllMapListModelsAtParentMapListModel : (MapListModel *)parentModel{
    NSUInteger startPosition = [_tempData indexOfObject:parentModel];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_tempData.count; i++) {
        MapListModel *model = [_tempData objectAtIndex:i];
        endPosition++;
        if (model.level <= parentModel.level) {
            break;
        }
        if(endPosition == _tempData.count-1){
            endPosition++;
            model.isExpand = NO;
            break;
        }
        model.isExpand = NO;
    }
    if (endPosition>startPosition) {
        [_tempData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    return endPosition;
}

@end
