/************************************************************
 Class    : MsgDetailViewCell.h
 Describe : 消息明细列表自定义cell
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-29
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <UIKit/UIKit.h>
@class MsgDetailModel, MsgDetailViewCell;

typedef NS_ENUM(NSInteger, MsgDetailViewCellMenuType) {
    MsgDetailViewCellMenuTypeCalendar,  // 添加日历提醒
    MsgDetailViewCellMenuTypeCopy,      // 复制
    MsgDetailViewCellMenuTypeDelete     // 删除
};

@protocol MsgDetailViewCellDelegate <NSObject>

-(void)msgDetailViewCellMenuClicked:(MsgDetailViewCell *)cell type:(MsgDetailViewCellMenuType)type;

@end

@interface MsgDetailViewCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) MsgDetailModel *model;

@property (nonatomic, weak) id<MsgDetailViewCellDelegate> delegate;

@end
