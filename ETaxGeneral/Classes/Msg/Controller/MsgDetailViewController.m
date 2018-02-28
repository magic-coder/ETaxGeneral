/************************************************************
 Class    : MsgDetailViewController.m
 Describe : 消息明细列表界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MsgDetailViewController.h"
#import "MsgRefreshHeader.h"
#import "MsgDetailViewCell.h"
#import "MsgDetailModel.h"
#import "MsgUtil.h"

@interface MsgDetailViewController () <UITableViewDelegate, UITableViewDataSource, MsgDetailViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;     // 消息数据内容列表
@property (nonatomic, assign) int pageNo;               // 页码值
@property (nonatomic, assign) int totalPage;            // 最大页

@end

@implementation MsgDetailViewController

static NSString * const reuseIdentifier = @"msgDetailCell";
static int const pageSize = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = [[NSMutableArray alloc] init];
    
    [self.view setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    //self.tableView.showsVerticalScrollIndicator = NO;   // 去掉右侧滚动条
    
    [self.tableView registerClass:[MsgDetailViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self loadData];    // 加载消息明细信息
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source数据源方法
#pragma mark 返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}
#pragma mark 返回每组条数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
#pragma mark 返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setModel:[_data objectAtIndex:indexPath.section]];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark 返回行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MsgDetailModel *model = [_data objectAtIndex:indexPath.section];
    return model.cellHeight;
}

#pragma mark 返回头视图高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    float h = 36.0f;
    
    if(section == 0){
        return h;
    }else{
        return 0.01f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    float h = 36.0f;
    return h;
}

#pragma mark 点击行触发点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 获取当前点击的cell
    MsgDetailViewCell *cell = (MsgDetailViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *url = cell.model.url;
    
    if(url.length > 0){
        BaseWebViewController *webVC = [[BaseWebViewController alloc] initWithURL:url];
        webVC.title = @"内容详情";
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

#pragma mark - <MsgDetailViewCellDelegate>菜单代理点击方法
- (void)msgDetailViewCellMenuClicked:(MsgDetailViewCell *)cell type:(MsgDetailViewCellMenuType)type{
    
    MsgDetailModel *model = cell.model;
    
    if(type == MsgDetailViewCellMenuTypeCalendar){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *currentDate = [[[BaseHandleUtil sharedBaseHandleUtil] currentDateTime] substringWithRange:NSMakeRange(0, 10)];
        
        NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 09:00:00", currentDate]];
        NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 18:00:00", currentDate]];
        NSString *notes = @"";
        if(model.url.length > 0){
            notes = [NSString stringWithFormat:@"详细内容请点击：%@", model.url];
        }
        
        NSString *alarmStr = [NSString stringWithFormat:@"%lf", 60.0f * -5.0f * 1];// 设置提醒时间为5分钟前
        
        [[BaseHandleUtil sharedBaseHandleUtil] createEventCalendarTitle:model.title location:model.content startDate:startDate endDate:endDate notes:(NSString *)notes allDay:NO alarmArray:@[alarmStr] block:^(NSString *msg) {
            if([msg isEqualToString:@"success"]){
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert showAlertWithTitle:@"提醒添加成功"
                             withSubtitle:@"是否打开\"日历\"查看、编辑提醒事件？"
                          withCustomImage:nil
                      withDoneButtonTitle:@"打开"
                               andButtons:@[@"取消"]];
                [alert makeAlertTypeSuccess];
                [alert doneActionBlock:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"] options:@{} completionHandler:nil];
                }];
            }else{
                [MBProgressHUD showHUDView:self.view text:msg progressHUDMode:YZProgressHUDModeShow];
            }
        }];
    }
    if(type == MsgDetailViewCellMenuTypeCopy){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard]; // 黏贴板
        NSString *pasteString = [NSString stringWithFormat:@"标题：%@", model.title];
        if(![model.user isEqualToString:@"系统推送"]){
            pasteString = [NSString stringWithFormat:@"%@\n推送人：%@", pasteString, model.user];
        }
        pasteString = [NSString stringWithFormat:@"%@\n时间：%@\n摘要：%@", pasteString, model.date, model.content];
        if(model.url.length > 0){
            pasteString = [NSString stringWithFormat:@"%@\n链接：%@", pasteString, model.url];
        }
        [pasteBoard setString:pasteString];
        DLog(@"Yan -> 复制内容结果为：%@", pasteString);
    }
    if(type == MsgDetailViewCellMenuTypeDelete){
        
        [YZBottomSelectView showBottomSelectViewWithTitle:@"是否删除该条消息？" cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            if(index == -1){
                [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
                [[MsgUtil sharedMsgUtil] deleteMsgDetailUuid:cell.model.uuid success:^{
                    // 删除成功，重新获取数据
                    [[MsgUtil sharedMsgUtil] loadMsgListPageNo:1 pageSize:100 success:^(NSDictionary *dataDict) {
                        [MBProgressHUD hiddenHUDView:self.view];
                        // 移除本行并重新加载数据
                        [_data removeObjectAtIndex:cell.indexPath.section];
                        [self.tableView reloadData];
                    } failure:^(NSString *error) {
                        [MBProgressHUD hiddenHUDView:self.view];
                        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
                    } invalid:^(NSString *msg) {
                        [MBProgressHUD hiddenHUDView:self.view];
                        SHOW_RELOGIN_VIEW
                    }];
                } failure:^(NSString *error) {
                    [MBProgressHUD hiddenHUDView:self.view];
                    [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
                } invalid:^(NSString *msg) {
                    [MBProgressHUD hiddenHUDView:self.view];
                    SHOW_RELOGIN_VIEW
                }];
            }
        }];
    }
}

#pragma mark - 加载数据
- (void)loadData{
    // 从服务器获取最新数据
    _pageNo = 1;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[NSNumber numberWithInt:_pageNo] forKey:@"pageNo"];
    [param setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    [param setObject:_sourceCode forKey:@"sourcecode"];
    if(_pushOrgCode == nil){
        _pushOrgCode = @"";
    }
    [param setObject:_pushOrgCode forKey:@"swjgdm"];
    
    [MBProgressHUD showHUDView:self.view text:nil progressHUDMode:YZProgressHUDModeLock];
    [[MsgUtil sharedMsgUtil] loadMsgDetailParameters:param success:^(NSDictionary *dataDict) {
        [MBProgressHUD hiddenHUDView:self.view];
        [self handleDataDict:dataDict];// 数据处理
        [self.tableView reloadData];
        [self reloadAfterMessage:NO];
        if(_totalPage > 1)
            // 设置下拉刷新
            self.tableView.mj_header = [MsgRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    } failure:^(NSString *error) {
        [MBProgressHUD hiddenHUDView:self.view];
        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
    } invalid:^(NSString *msg) {
        [MBProgressHUD hiddenHUDView:self.view];
        SHOW_RELOGIN_VIEW
    }];
}

#pragma mark - 加载更多方法
- (void)loadMoreData{
    _pageNo++;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[NSNumber numberWithInt:_pageNo] forKey:@"pageNo"];
    [param setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    [param setObject:_sourceCode forKey:@"sourcecode"];
    [param setObject:_pushOrgCode forKey:@"swjgdm"];
    
    [[MsgUtil sharedMsgUtil] loadMsgDetailParameters:param success:^(NSDictionary *dataDict) {
        // 加载结束
        [self.tableView.mj_header endRefreshing];
        if(_pageNo == _totalPage){
            self.tableView.mj_header = nil;
        }
        
        NSArray *results = [dataDict objectForKey:@"results"];
        // 逆序小日期在前大日期在后
        for(NSDictionary *dict in results){
            MsgDetailModel *model = [MsgDetailModel createWithDictionary:dict];
            [_data insertObject:model atIndex:0];
        }
        [self.tableView reloadData];
    } failure:^(NSString *error) {
        _pageNo--;
        // 加载结束
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
    } invalid:^(NSString *msg) {
        SHOW_RELOGIN_VIEW
    }];

}

#pragma mark - 处理数据
-(void)handleDataDict:(NSDictionary *)dict{
    _data = [[NSMutableArray alloc] init];
    
    _totalPage = [[dict objectForKey:@"totalPage"] intValue];
    
    NSArray *results = [dict objectForKey:@"results"];
    // 逆序小日期在前大日期在后
    for(int i = (int)results.count -1; i >= 0; i--){
        MsgDetailModel *model = [MsgDetailModel createWithDictionary:results[i]];
        [_data addObject:model];
    }
}

#pragma mark - 视图滚动到最底部
- (void)reloadAfterMessage:(BOOL)show {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.data.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.data.count - 1];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:show];
        }
    });
}

@end
