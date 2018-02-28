/************************************************************
 Class    : BaseTableViewHeaderFooterView.h
 Describe : 基本的表格头部、底部视图
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@interface BaseTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *text;

+ (CGFloat) getHeightForText:(NSString *)text;

@end
