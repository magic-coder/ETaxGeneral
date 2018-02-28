/************************************************************
 Class    : AppSearchTableView.h
 Describe : 应用搜索的tableView，触摸代理方法（点击隐藏键盘）
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-23
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@protocol AppSearchTableViewDelegate <NSObject>

@optional
/**
 *  重写touch方法时必须把父类实现方法写上，否则UITableViewCell将无法正常工作。所有的改写工作如下所示，新的TableView类具有touch事件响应了。
 */
- (void)tableView:(UITableView *)tableView
touchesBegan:(NSSet *)touches
withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
touchesCancelled:(NSSet *)touches
withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
touchesEnded:(NSSet *)touches
withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
touchesMoved:(NSSet *)touches
withEvent:(UIEvent *)event;

@end

@interface AppSearchTableView : UITableView

@property (nonatomic, weak) id<AppSearchTableViewDelegate> touchDelegate;

@end
