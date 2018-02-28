/************************************************************
 Class    : LeftMenuView.m
 Describe : 自定义左侧菜单展示
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "LeftMenuView.h"

@interface LeftMenuView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *orgLabel;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *versionLabel;

@property (nonatomic, assign) float cellFontSize;

@property (nonatomic, strong) UITableView *contentTableView;

@end

@implementation LeftMenuView

 
-(instancetype)initWithFrame:(CGRect)frame{

    if(self = [super initWithFrame:frame]){
        [self initView];
    }
    return  self;
}

-(void)initView{

    self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    float headerH = 120.0f;
    float avatarWH = 60.0f;
    float labelH = 20.0f;
    
    float nameFontSize = 18.0f;
    float orgFontSize = 14.0f;
    float versionFontSize = 12.0f;
    
    _cellFontSize = 15.0f;
    
    if(DEVICE_SCREEN_INCH_IPAD){
        headerH = 160.0f;
        
        nameFontSize = 20.0f;
        orgFontSize = 16.0f;
        versionFontSize = 14.0f;
        
        _cellFontSize = 17.0f;
    }
    
    //添加头部
    _headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg"]];
    _headerView.frame = CGRectMake(0, 0, self.frameWidth, HEIGHT_STATUS+headerH);
    [self addSubview:_headerView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(ceilf((CGFloat)self.frameWidth/8)-avatarWH/2, HEIGHT_STATUS+(headerH/4), avatarWH, avatarWH)];
    [_avatarView setImage:[UIImage imageNamed:@"mine_account_header_color"]];
    [_headerView addSubview:_avatarView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarView.frameRight+5, _avatarView.originY+5, self.frameWidth-_avatarView.frameRight-10, labelH)];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:nameFontSize];
    [_headerView addSubview:_nameLabel];
    
    _orgLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.originX, _avatarView.frameBottom-labelH-5, _nameLabel.frameWidth, labelH)];
    _orgLabel.textAlignment = NSTextAlignmentCenter;
    _orgLabel.textColor = [UIColor whiteColor];
    _orgLabel.font = [UIFont systemFontOfSize:orgFontSize];
    [_headerView addSubview:_orgLabel];
    
    //中间tableview
    _contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headerView.frameBottom, self.frameWidth, self.frameHeight - _headerView.frameHeight) style:UITableViewStylePlain];
    [_contentTableView setBackgroundColor:[UIColor whiteColor]];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_contentTableView setBackgroundColor:[UIColor whiteColor]];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.tableFooterView = [UIView new];
    [self addSubview:_contentTableView];
    
    //添加尾部
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frameHeight - 60, self.frameWidth, 60)];
    [_footerView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_footerView];
    
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _footerView.frameWidth, 30)];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    _versionLabel.textColor = [UIColor lightGrayColor];
    _versionLabel.font = [UIFont systemFontOfSize:versionFontSize];
    [_footerView addSubview:_versionLabel];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float h = 46.0f;
    if(DEVICE_SCREEN_INCH_IPAD)
        h = 60.0f;
    return h;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"leftMenuViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    cell.textLabel.font = [UIFont systemFontOfSize:_cellFontSize];
    cell.hidden = NO;
    switch (indexPath.row) {
        case 0: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_mine"]];
            [cell.textLabel setText:@"个人信息"];
            break;
        }
        case 1: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_sign"]];
            [cell.textLabel setText:@"每日签到"];
            break;
        }
        case 2: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_introduce"]];
            [cell.textLabel setText:@"功能介绍"];
            break;
        }
        case 3: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_problem"]];
            [cell.textLabel setText:@"常见问题"];
            break;
        }
        case 4: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_service"]];
            [cell.textLabel setText:@"联系客服"];
            break;
        }
        case 5: {
            [cell.imageView setImage:[UIImage imageNamed:@"menu_setting"]];
            [cell.textLabel setText:@"设置"];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.delegate respondsToSelector:@selector(leftMenuViewClick:)]){
        [self.delegate leftMenuViewClick:indexPath.row];
    }
    
}

#pragma mark -  设置展示数据（包含，姓名、机构等...）
- (void)loadData {
    NSDictionary *loginDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS];// 登录基本信息
    _nameLabel.text = [loginDict objectForKey:@"userName"]; // 用户名称
    _orgLabel.text = [loginDict objectForKey:@"orgName"];   // 机构名称
    
    // 版本信息
    _versionLabel.text = [NSString stringWithFormat:@"For iPhone V%@ build%@", [[Variable sharedVariable] appVersion], [[Variable sharedVariable] buildVersion]];
}
#pragma mark - 清空已经存在的数据
- (void)clearData {
    _nameLabel.text = @"";
    _orgLabel.text = @"";
}

@end
