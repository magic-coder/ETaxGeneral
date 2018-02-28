/************************************************************
 Class    : YBPopupMenu+YZ.m
 Describe : 自定义YBPopupMenu的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-24
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "YBPopupMenu+YZ.h"

@implementation YBPopupMenu (YZ)

#pragma mark - 快速创建并展示弹出气泡菜单（展示坐标在右上角）
+ (void)showPopupMenuWithTitles:(NSArray *)titles icons:(NSArray *)icons delegate:(id<YBPopupMenuDelegate>)delegate {
    
    [YBPopupMenu showAtPoint:CGPointMake(WIDTH_SCREEN-25.0f, HEIGHT_STATUS+HEIGHT_NAVBAR+5) titles:titles icons:icons menuWidth:125.0f otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.cornerRadius = 3.0f;
        popupMenu.arrowWidth = 9.0f;
        popupMenu.arrowHeight = 6.0f;
        popupMenu.fontSize = 14.0f;
        popupMenu.itemHeight = 38.0f;
        popupMenu.textColor = HexColor(@"#515151", 1.0f);
        popupMenu.delegate = delegate;
    }];
    
}

@end
