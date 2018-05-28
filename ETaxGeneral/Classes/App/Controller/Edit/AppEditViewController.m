/************************************************************
 Class    : AppEditViewController.m
 Describe : 应用管理编辑模块视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-31
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "AppEditViewController.h"
#import "AppEditViewCell.h"
#import "AppEditHeaderView.h"
#import "AppModel.h"
#import "AppUtil.h"

@interface AppEditViewController () <AppEditViewCellDelegate>
{
    NSMutableDictionary *_dataDict;
}
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation AppEditViewController

static NSString * const reuseCellIdentifier = @"reuseCellIdentifier";
static NSString * const reuseHeaderIdentifier = @"reuseHeaderIdentifier";


- (instancetype)init {
    
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;// 确定是水平滚动，还是垂直滚动
    _flowLayout.minimumLineSpacing = 0;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return [super initWithCollectionViewLayout:_flowLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的应用管理";
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;// 总是可垂直滑动
    self.collectionView.showsVerticalScrollIndicator = NO; // 隐藏垂直滚动条
    
    // Register cell classes
    [self.collectionView registerClass:[AppEditViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    [self.collectionView registerClass:[AppEditHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    
    //添加导航栏右侧按钮
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(editAppData:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;// 初始化保存按钮不可点击
    
    [self initializeData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;// 设置顶部状态栏字体为黑色
    self.navigationController.navigationBar.tintColor = DEFAULT_BLUE_COLOR;// 设置导航栏itemBar字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };// 设置导航栏title标题字体颜色
    self.jz_navigationBarTintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;// 设置顶部状态栏字体颜色为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];// 设置导航栏itemBar字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };// 设置导航栏title标题字体颜色
    self.jz_navigationBarTintColor = DEFAULT_BLUE_COLOR;
}

#pragma mark - 初始化加载数据
- (void)initializeData {
    _dataDict = [[AppUtil sharedAppUtil] loadAppData];
    if(_dataDict){
        [self handleData:_dataDict];
    }else{
        [[AppUtil sharedAppUtil] initAppDataSuccess:^(NSMutableDictionary *dataDict) {
            _dataDict = dataDict;
            [self handleData:_dataDict];
        } failure:^(NSString *error) {
            [MBProgressHUD showHUDView:self.view text:error progressHUDMode:YZProgressHUDModeShow];
        } invalid:^(NSString *msg) {
            SHOW_RELOGIN_VIEW
        }];
    }
}

#pragma mark - 处理数据
- (void)handleData:(NSMutableDictionary *)data{
    NSArray *mineAppData = [data objectForKey:@"mineData"];
    NSMutableArray *allGroupData = [data objectForKey:@"allGroupData"];
    // 对其他应用进行分组排序
    
    _data = [NSMutableArray array];
    
    NSMutableArray *mineArray = [NSMutableArray array];
    for(NSDictionary *dict in mineAppData){
        AppModelItem *item = [AppModelItem createWithDictionary:dict];
        [mineArray addObject:item];
    }
    AppModelGroup *mineGroup = [[AppModelGroup alloc] init];
    mineGroup.items = mineArray;
    mineGroup.groupTitle = @"我的应用";
    [_data addObject:mineGroup];
    
    for(NSDictionary *dict in allGroupData){
        NSMutableArray *otherArray = [NSMutableArray array];
        for (NSDictionary *appDic in dict[@"appArray"]) {
            AppModelItem *item = [AppModelItem createWithDictionary:appDic];
            [otherArray addObject:item];
        }
        AppModelGroup *otherGroup = [[AppModelGroup alloc] init];
        otherGroup.items = otherArray;
        otherGroup.groupTitle = dict[@"groupName"];
        [_data addObject:otherGroup];
    }
}

#pragma mark - <UICollectionViewDataSource> 数据源方法
#pragma mark 返回有多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

#pragma mark 返回每组多少条
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    AppModelGroup *group = [self.data objectAtIndex:section];
    return group.itemsCount;
}

#pragma mark 返回每个cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    AppModelGroup *group = [_data objectAtIndex:indexPath.section];
    AppModelItem *item = [group itemAtIndex:indexPath.row];
    
    AppEditViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    
    //第一组为我的应用
    if(indexPath.section == 0){
        cell.editBtnStyle = AppCellEditBtnStyleDelete;
    }else{  // 剩下的为其他应用
        cell.editBtnStyle = AppCellEditBtnStyleAdd;
        AppModelGroup *groupMine = [self.data objectAtIndex:0];
        // 循环判断“全部应用”中哪些为“我的应用”，设置编辑按钮样式
        [groupMine.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AppModelItem *mineItem = (AppModelItem *)obj;
            if([mineItem.no isEqualToString:item.no]){
                cell.editBtnStyle = AppCellEditBtnStyleSelected;
            }
        }];
    }
    
    cell.delegate = self;
    
    [cell setItem:item];
    
    return cell;
}

#pragma mark 设置cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor((CGFloat)(collectionView.frameWidth)/4);
    return CGSizeMake(width, width);
}

#pragma mark 设置cell上下间隙
-(CGFloat )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - <UICollectionViewDelegate> 代理方法
#pragma mark 设置每组的顶部视图
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    AppEditHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        AppModelGroup *group = [_data objectAtIndex:indexPath.section];
        headerView.title = group.groupTitle;
    }
    
    return headerView;
}

#pragma mark 设置顶部视图的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return (CGSize){WIDTH_SCREEN, 32.0f};
}

#pragma mark - 代理编辑按钮点击方法
- (void)appEditViewCellEditBtnClick:(UIButton *)sender {
    
    UIView *view = [sender superview];//获取父类view
    AppEditViewCell *cell = (AppEditViewCell *)[view superview];//获取cell
    NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];//获取cell对应的indexpath;
    
    if(sender.tag == 0){    // 移除方法
        //DLog(@"进入移除方法 -> senction = %ld, row = %ld",(long)indexpath.section,(long)indexpath.row);
        
        AppModelGroup *mineGroup = [self.data objectAtIndex:0];
        if(mineGroup.itemsCount > 1){
            AppModelItem *delItem = [mineGroup.items objectAtIndex:indexpath.row];
            [mineGroup.items removeObject:delItem];
        }else{
            [MBProgressHUD showHUDView:self.view text:@"已经是最后一个我的应用了" progressHUDMode:YZProgressHUDModeShow];
        }
    }
    if(sender.tag == 1){    // 添加方法
        //DLog(@"进入添加方法 -> senction = %ld, row = %ld",(long)indexpath.section,(long)indexpath.row);
        AppModelGroup *mineGroup = [self.data objectAtIndex:0];
        if(mineGroup.itemsCount < 12){
            AppModelGroup *allGroup = [self.data objectAtIndex:indexpath.section];
            AppModelItem *addItem = [allGroup.items objectAtIndex:indexpath.row];
            [mineGroup.items addObject:addItem];
        }else{
            [MBProgressHUD showHUDView:self.view text:@"最多添加12个我的应用" progressHUDMode:YZProgressHUDModeShow];
        }
    }
    [self.collectionView reloadData];
    // 点击编辑按钮后设置保存按钮可点击
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - 编辑方法
- (void)editAppData:(UIBarButtonItem *)sender{
    // 点击保存后暂时不能再次点击按钮
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // 点击保存将数据写入SandBox覆盖以前数据
    AppModelGroup *mineGroup = [self.data objectAtIndex:0];
    NSMutableArray *mineData = [[NSMutableArray alloc] init];
    // 我的应用数据
    int ids = 1;
    for(AppModelItem *mineItem in mineGroup.items){
        DLog(@"mineItem.url = %@", mineItem.url);
        NSDictionary *mineDict = [NSDictionary dictionaryWithObjectsAndKeys: mineItem.no, @"appno", mineItem.title, @"appname", mineItem.webImg, @"appimage", mineItem.url, @"appurl", [NSString stringWithFormat:@"%d", ids], @"userappsort", @"1", @"apptype", mineItem.isNewApp ? @"Y" : @"N", @"isnewapp", nil];
        [mineData addObject:mineDict];
        ids++;
    }
    [_dataDict setValue:mineData forKey:@"mineData"];
    
    // 向服务器提交自定义app数据
    [[AppUtil sharedAppUtil] saveCustomData:mineData success:^(id responseObject) {
        [MBProgressHUD showHUDView:self.view text:@"保存成功!" progressHUDMode:YZProgressHUDModeShow];
        // 写入本地
        BOOL res = [[AppUtil sharedAppUtil] writeAppData:_dataDict];
        if (!res) {
            DLog(@"App写入本地失败!");
        }
        // 点击编辑按钮后设置保存按钮不可点击
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } failure:^(NSString *error) {
        [MBProgressHUD showHUDView:self.view text:@"保存失败，请检查原因！" progressHUDMode:YZProgressHUDModeShow];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } invalid:^(NSString *msg) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

@end
