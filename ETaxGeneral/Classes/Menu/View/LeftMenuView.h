/************************************************************
 Class    : LeftMenuView.h
 Describe : 自定义左侧菜单展示
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-15
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>

@protocol LeftMenuViewDelegate <NSObject>

-(void)leftMenuViewClick:(NSInteger)tag;

@end

@interface LeftMenuView : UIView

@property (nonatomic ,weak)id <LeftMenuViewDelegate> delegate;

- (void)loadData;// 加载数据
- (void)clearData;// 清空数据

@end
