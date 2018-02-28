/************************************************************
 Class    : YBPopupMenu+YZ.h
 Describe : 自定义YBPopupMenu的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "YBPopupMenu.h"

@interface YBPopupMenu (YZ)

// 快速创建并展示弹出气泡菜单（展示坐标在右上角）
+ (void)showPopupMenuWithTitles:(NSArray *)titles icons:(NSArray *)icons delegate:(id<YBPopupMenuDelegate>)delegate;

@end
