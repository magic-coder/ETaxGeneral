/************************************************************
 Class    : MineUtil.m
 Describe : 我的模块处理工具类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-07
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MineUtil.h"
#import "BaseTableModel.h"

#import <UserNotifications/UserNotifications.h>

@interface MineUtil()

@property (nonatomic, strong) NSString *noticeSubTitle;

@end

@implementation MineUtil

SingletonM(MineUtil)

#pragma mark - 我的数据（第一级）
- (NSMutableArray *)mineData {
    
    NSMutableArray *items = [NSMutableArray array];
    
    BaseTableModelItem *safe = [BaseTableModelItem createWithImageName:@"mine_safe" title:@"安全中心"];
    BaseTableModelItem *schedule = [BaseTableModelItem createWithImageName:@"mine_schedule" title:@"我的日程"];
    BaseTableModelItem *service = [BaseTableModelItem createWithImageName:@"mine_service" title:@"我的客服"];
    
    BaseTableModelGroup *group1 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:safe, schedule, service, nil];
    [items addObject:group1];
    
    BaseTableModelItem *setting = [BaseTableModelItem createWithImageName:@"mine_setting" title:@"设置"];
    
    BaseTableModelGroup *group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:setting, nil];
    [items addObject:group2];
    
    BaseTableModelItem *opinion = [BaseTableModelItem createWithImageName:@"mine_opinion" title:@"系统评价"];
    BaseTableModelItem *about = [BaseTableModelItem createWithImageName:@"mine_about" title:@"关于"];
    
    BaseTableModelGroup *group3 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:opinion, about, nil];
    [items addObject:group3];
    
    /*
    BaseTableModelItem *test = [BaseTableModelItem createWithImageName:@"mine_test" title:@"测试"];
    
    BaseTableModelGroup *group4 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:test, nil];
    [items addObject:group4];
     */
    
    return items;
    
}

#pragma mark - 我的用户信息（第二级）
- (NSMutableArray *)accountData {
    
    NSDictionary *loginDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SUCCESS];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    BaseTableModelItem *userID = [BaseTableModelItem createWithTitle:@"姓名" subTitle:[loginDict objectForKey:@"userName"]];
    userID.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group1 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:userID, nil];
    [items addObject:group1];
    
    BaseTableModelItem *name = [BaseTableModelItem createWithTitle:@"账号" subTitle:[loginDict objectForKey:@"userCode"]];
    name.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelItem *phoneNum = [BaseTableModelItem createWithTitle:@"手机号" subTitle:[loginDict objectForKey:@"userMobile"]];
    phoneNum.accessoryType = UITableViewCellAccessoryNone;
    //BaseTableModelItem *barCode = [BaseTableModelItem createWithImageName:nil title:@"我的二维码" subTitle:nil rightImageName:@"mine_barcode"];
    //barCode.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelItem *organ = [BaseTableModelItem createWithTitle:@"所属部门" subTitle:[loginDict objectForKey:@"orgName"]];
    organ.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:name, phoneNum, organ, nil];
    [items addObject:group2];
    
    
    BaseTableModelItem *lastTime = [BaseTableModelItem createWithTitle:@"上次登录时间" subTitle:[loginDict objectForKey:@"loginDate"]];
    lastTime.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group3 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:lastTime, nil];
    [items addObject:group3];
    
    BaseTableModelItem *exit = [BaseTableModelItem createWithTitle:@"退出登录"];
    exit.alignment = BaseTableModelItemAlignmentMiddle;
    exit.titleColor = DEFAULT_RED_COLOR;
    
    BaseTableModelGroup *group4 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:exit, nil];
    [items addObject:group4];
    
    return items;
    
}

#pragma mark - 安全中心数据（第二级）
- (NSMutableArray *)safeData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    
    BOOL gesturePwdOn = [[settingDict objectForKey:@"gesturePwd"] boolValue];
    NSString *gesturePwd = [[NSUserDefaults standardUserDefaults] objectForKey:GESTURES_PASSWORD];
    
    BaseTableModelItem *item2 = [BaseTableModelItem createWithTitle:@"手势密码"];
    item2.type = BaseTableModelItemTypeSwitch;
    item2.tag = 422;
    item2.isOn = gesturePwdOn;
    
    BaseTableModelGroup *group2 = nil;
    if(YES == gesturePwdOn && gesturePwd.length > 0){
        BaseTableModelItem *item2_1 = [BaseTableModelItem createWithTitle:@"修改手势密码"];
        group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:item2, item2_1, nil];
    }else{
        group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:item2, nil];
    }
    [items addObject:group2];
    
    
    BOOL touchIDOn = [[settingDict objectForKey:@"touchID"] boolValue];
    
    BaseTableModelItem *item3 = [BaseTableModelItem createWithTitle:@"指纹解锁"];
    item3.type = BaseTableModelItemTypeSwitch;
    item3.tag = 423;
    item3.isOn = touchIDOn;
    BaseTableModelGroup *group3 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:@"若要开启指纹解锁功能，请先在\"设置\"-\"Touch ID 与密码\"中添加指纹。" settingItems:item3, nil];
    [items addObject:group3];
    
    return items;
}

#pragma mark - 我的日程数据（第二级）
- (NSMutableArray *)scheduleData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    BaseTableModelItem *item1 = [BaseTableModelItem createWithTitle:@"日程提醒管理"];
    BaseTableModelItem *item2= [BaseTableModelItem createWithTitle:@"税务日历"];
    BaseTableModelGroup *group1 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:item1, item2, nil];
    [items addObject:group1];
    
    return items;
}

#pragma mark - 我的客服数据（第二级）
- (NSMutableArray *)serviceData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    BaseTableModelItem *item1 = [BaseTableModelItem createWithTitle:@"客服电话" subTitle:@"029-87663504"];
    item1.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelItem *item2 = [BaseTableModelItem createWithTitle:@"客服邮箱" subTitle:@"yanzheng@prient.com"];
    item2.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group1 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:item1, item2, nil];
    [items addObject:group1];
    
    BaseTableModelItem *item3= [BaseTableModelItem createWithTitle:@"常见问题"];
    BaseTableModelGroup *group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems:item3, nil];
    [items addObject:group2];
    
    return items;
}

#pragma mark - 设置数据（第二级）
- (NSMutableArray *)settingData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // 判断用户是否打开消息通知
    /*
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if(settings.authorizationStatus == UNAuthorizationStatusNotDetermined)
            // 未选择，没有选择允许或者不允许，按不允许处理
            _noticeSubTitle = @"未开启";
        if(settings.authorizationStatus == UNAuthorizationStatusDenied)
            // 未授权，不允许推送
            _noticeSubTitle = @"已关闭";
        if(settings.authorizationStatus == UNAuthorizationStatusAuthorized)
            // 已授权，允许推送
            _noticeSubTitle = @"已开启";
    }];
    */
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        _noticeSubTitle = @"已开启";
    }else{
        _noticeSubTitle = @"已关闭";
    }
    
    NSString *appName = [[Variable sharedVariable] appName];
    
    BaseTableModelItem *recNoti = [BaseTableModelItem createWithTitle:@"接收新消息通知" subTitle:_noticeSubTitle];
    recNoti.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group1 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:[NSString stringWithFormat:@"如果你要关闭或开启\"%@\"的新消息通知，请在iPhone的\"设置\"-\"通知\"功能中，找到应用程序\"%@\"更改。", appName, appName] settingItems:recNoti, nil];
    [items addObject:group1];
    
    // 获取声音、震动、更新设置的值
    NSDictionary *settingDict = [[BaseSettingUtil sharedBaseSettingUtil] loadSettingData];
    BOOL voiceOn = [[settingDict objectForKey:@"voice"] boolValue];
    BOOL shakeOn = [[settingDict objectForKey:@"shake"] boolValue];
    
    BaseTableModelItem *voice = [BaseTableModelItem createWithTitle:@"声音"];
    voice.type = BaseTableModelItemTypeSwitch;
    voice.tag = 452;
    voice.isOn = voiceOn;
    BaseTableModelItem *shake = [BaseTableModelItem createWithTitle:@"震动"];
    shake.type = BaseTableModelItemTypeSwitch;
    shake.tag = 453;
    shake.isOn = shakeOn;
    BaseTableModelGroup *group2 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:[NSString stringWithFormat:@"当\"%@\"在运行时，你可以设置是否需要声音或者振动。", appName] settingItems:voice, shake, nil];
    [items addObject:group2];
    
    BOOL sysVoiceOn = [[settingDict objectForKey:@"sysVoice"] boolValue];
    BaseTableModelItem *sysVoice = [BaseTableModelItem createWithTitle:@"系统特效"];
    sysVoice.type = BaseTableModelItemTypeSwitch;
    sysVoice.tag = 454;
    sysVoice.isOn = sysVoiceOn;
    BaseTableModelGroup *group3 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:@"包括刷新、点击按钮时反馈的音效及动画" settingItems: sysVoice, nil];
    [items addObject:group3];
    
    float tempSize = [[SDImageCache sharedImageCache] getSize]/1024;
    NSString *cacheSize = tempSize >= 1024 ? [NSString stringWithFormat:@"%.1fMB",tempSize/1024] : [NSString stringWithFormat:@"%.1fKB",tempSize];
    BaseTableModelItem *clear = [BaseTableModelItem createWithTitle:@"清理缓存" subTitle:cacheSize];
    clear.accessoryType = UITableViewCellAccessoryNone;
    BaseTableModelGroup *group5 = [[BaseTableModelGroup alloc] initWithHeaderTitle:nil footerTitle:nil settingItems: clear, nil];
    [items addObject:group5];
    
    return items;
}

@end

