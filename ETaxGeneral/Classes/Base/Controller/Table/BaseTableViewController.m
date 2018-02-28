/************************************************************
 Class    : BaseTableViewController.m
 Describe : 基本的表格视图控制器，提供Table布局界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseTableViewController.h"
#import "BaseTableViewCell.h"
#import "BaseTableViewHeaderFooterView.h"

@interface BaseTableViewController ()<UITableViewDelegate, UITableViewDataSource, BaseTableViewCellDelegate>

@end

@implementation BaseTableViewController

static NSString * const reuseIdentifier = @"baseTableViewCell";
static NSString * const headerFooterViewReuseIdentifier = @"baseHeaderFooterView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - <UITableViewDataSource>数据源方法
#pragma mark 返回有多少组
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data.count;
}

#pragma mark 返回每组条数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BaseTableModelGroup *group = [_data objectAtIndex:section];
    return group.itemsCount;
}

#pragma mark 返回每行cell
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BaseTableModelGroup *group = [_data objectAtIndex:indexPath.section];   // 获得组
    BaseTableModelItem *item = [group itemAtIndex:indexPath.row];   // 获得组中的元素
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setItem:item];
    
    // cell分割线
    if (item.type != BaseTableModelItemTypeButton) {
        indexPath.row == 0 ? [cell setTopLineStyle:CellLineStyleFill] : [cell setTopLineStyle:CellLineStyleNone];
        indexPath.row == group.itemsCount - 1 ? [cell setBottomLineStyle:CellLineStyleFill] : [cell setBottomLineStyle:CellLineStyleDefault];
    }else {
        [cell setTopLineStyle:CellLineStyleNone];
        [cell setBottomLineStyle:CellLineStyleNone];
    }
    
    cell.delegate = self; // 为按钮的时候设置代理方法（按钮、Switch点击事件）
    
    return cell;
}

#pragma mark - <UITableViewDelegate>代理方法
#pragma mark 设置tableView顶部视图
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BaseTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooterViewReuseIdentifier];
    if (_data && _data.count > section) {
        BaseTableModelGroup *group = [_data objectAtIndex:section];
        [view setText:group.headerTitle];
    }
    return view;
}

#pragma mark 设置tableView底部视图
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    BaseTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooterViewReuseIdentifier];
    if (_data && _data.count > section) {
        BaseTableModelGroup *group = [_data objectAtIndex:section];
        [view setText:group.footerTitle];
    }
    return view;
}

#pragma mark 设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_data && _data.count > indexPath.section) {
        BaseTableModelGroup *group = [_data objectAtIndex:indexPath.section];
        BaseTableModelItem *item = [group itemAtIndex:indexPath.row];
        return [BaseTableViewCell getHeightForText:item];
    }
    return 0.0f;
}

#pragma mark 设置Header顶部视图的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_data && _data.count > section) {
        BaseTableModelGroup *group = [_data objectAtIndex:section];
        if (group.headerTitle == nil) {
            return section == 0 ? 20.0f : 10.0f;
        }
        return [BaseTableViewHeaderFooterView getHeightForText:group.headerTitle];
    }
    return 10.0f;
}

#pragma mark 设置Footer底部视图的高度
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_data && _data.count > section) {
        BaseTableModelGroup *group = [_data objectAtIndex:section];
        if (group.footerTitle == nil) {
            return section == _data.count - 1 ? 30.0f : 10.0f;
        }
        return [BaseTableViewHeaderFooterView getHeightForText:group.footerTitle];
    }
    return 10.0f;
}

#pragma mark - <BaseTableViewCellDelegate> 代理方法按钮的点击方法
-(void)baseTableViewCellBtnClick:(UIButton *)sender{
    // 如果协议响应了baseTableViewControllerBtnClick:方法
    if([_delegate respondsToSelector:@selector(baseTableViewControllerBtnClick:)]){
        [_delegate baseTableViewControllerBtnClick:sender]; // 通知执行协议方法
    }
}

#pragma mark - <BaseTableViewCellDelegate> 代理方法Switch的选择方法
-(void)baseTableViewCellSwitchChanged:(UISwitch *)sender{
    // 如果协议响应了baseTableViewControllerSwitchChanged:方法
    if([_delegate respondsToSelector:@selector(baseTableViewControllerSwitchChanged:)]){
        [_delegate baseTableViewControllerSwitchChanged:sender]; // 通知执行协议方法
    }
}

- (UITableView *)tableView {
    if(nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [_tableView setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)]];
        // 隐藏UITableViewStyleGrouped上边多余的间隔
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        
        [_tableView registerClass:[BaseTableViewCell class] forCellReuseIdentifier:reuseIdentifier];// 注册cell视图
        [_tableView registerClass:[BaseTableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:headerFooterViewReuseIdentifier];// 注册Header、Footer的cell
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];// 隐藏TableView的分割线
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)setData:(NSMutableArray *)data{
    _data = data;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
