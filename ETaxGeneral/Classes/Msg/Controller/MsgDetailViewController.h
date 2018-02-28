/************************************************************
 Class    : MsgDetailViewController.h
 Describe : 消息明细列表界面
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseViewController.h"

@interface MsgDetailViewController : BaseViewController

@property (nonatomic, strong) NSString *sourceCode;     // 来源代码
@property (nonatomic, strong) NSString *pushOrgCode;   // 推送机构代码

@end
