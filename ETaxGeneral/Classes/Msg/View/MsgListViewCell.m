/************************************************************
 Class    : MsgListViewCell.m
 Describe : 消息分组列表自定义cell
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MsgListViewCell.h"
#import "MsgListModel.h"

@interface MsgListViewCell()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) float leftFreeSpace;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIImageView *redMarkView;
@property (nonatomic, strong) UILabel *redMark;

@end

@implementation MsgListViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _topLineStyle = CellLineStyleNone;
        _bottomLineStyle = CellLineStyleDefault;
        
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.msgLabel];
        [self addSubview:self.redMarkView];
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
    [self.topLine setOriginY:0];
    [self.bottomLine setOriginY:self.frameHeight - _bottomLine.frameHeight];
    [self setBottomLineStyle:_bottomLineStyle];
    [self setTopLineStyle:_topLineStyle];
    
    //self.leftFreeSpace = self.frameHeight * 0.18;
    self.leftFreeSpace = 12.0f;
    
    float imageWidth = floorf(self.frameHeight * 0.72f);
    float space = self.leftFreeSpace;
    [self.avatarView setFrame:CGRectMake(space, space, imageWidth, imageWidth)];
    
    float redMarkX = space + imageWidth;
    float redMarkY = space;
    float redMarkW = 24.0f;
    float redMarkH = 24.0f;
    [self.redMarkView setFrame:CGRectMake(redMarkX - redMarkW/2, redMarkY - redMarkH/2, redMarkW, redMarkH)];
    
    float labelX = space * 2 + imageWidth;
    float labelY = self.frameHeight * 0.135f;
    float labelHeight = self.frameHeight * 0.4f;
    float labelWidth = self.frameWidth - labelX - space * 1.5f;
    
    float dateWidth = 120.0f;
    float dateHeight = labelHeight * 0.75f;
    float dateX = self.frameWidth - space - dateWidth;
    [self.dateLabel setFrame:CGRectMake(dateX, labelY * 0.7f, dateWidth, dateHeight)];
    
    float usernameLabelWidth = self.frameWidth - labelX - dateWidth - space;
    [self.nameLabel setFrame:CGRectMake(labelX, labelY, usernameLabelWidth, labelHeight)];
    
    labelY = self.frameHeight * 0.91f - labelHeight;
    [self.msgLabel setFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
}

- (void) setModel:(MsgListModel *)model{
    _model = model;
    
    [self.avatarView setImage:[UIImage imageNamed:_model.avatar]];
    [self.nameLabel setText:_model.name];
    [self.dateLabel setText:_model.date];
    [self.msgLabel setText:_model.message];
    
    if([_model.unReadCount intValue] > 0){
        self.redMarkView.hidden = NO;
        [self.redMark setText:_model.unReadCount];
    }else{
        self.redMarkView.hidden = YES;
    }
    
    [self layoutSubviews];
}

#pragma mark - Common Getter and Setter
- (UIView *) topLine{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        [_topLine setFrameHeight:0.5f];
        [_topLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
        //[_topLine setAlpha:0.4];
        [self.contentView addSubview:_topLine];
    }
    return _topLine;
}

- (UIView *) bottomLine{
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        [_bottomLine setFrameHeight:0.5f];
        [_bottomLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
        //[_bottomLine setAlpha:0.4];
        [self.contentView addSubview:_bottomLine];
    }
    return _bottomLine;
}

- (void) setTopLineStyle:(CellLineStyle)style{
    _topLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.topLine setOriginX:_leftFreeSpace];
        [self.topLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.topLine setHidden:NO];
    }else if (style == CellLineStyleFill) {
        [self.topLine setOriginX:0];
        [self.topLine setFrameWidth:self.frameWidth];
        [self.topLine setHidden:NO];
    }else if (style == CellLineStyleNone) {
        [self.topLine setHidden:YES];
    }
}

- (void) setBottomLineStyle:(CellLineStyle)style{
    _bottomLineStyle = style;
    if (style == CellLineStyleDefault) {
        [self.bottomLine setOriginX:_leftFreeSpace];
        [self.bottomLine setFrameWidth:self.frameWidth - _leftFreeSpace];
        [self.bottomLine setHidden:NO];
    }else if (style == CellLineStyleFill) {
        [self.bottomLine setOriginX:0];
        [self.bottomLine setFrameWidth:self.frameWidth];
        [self.bottomLine setHidden:NO];
    }else if (style == CellLineStyleNone) {
        [self.bottomLine setHidden:YES];
    }
}

#pragma mark - Getter
- (UIImageView *) avatarView{
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:5.0f];
    }
    return _avatarView;
}

- (UILabel *) nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:16.0f]];
    }
    return _nameLabel;
}

- (UILabel *) dateLabel{
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] init];
        [_dateLabel setAlpha:0.8];
        [_dateLabel setTextAlignment:NSTextAlignmentRight];
        [_dateLabel setTextColor:[UIColor grayColor]];
        [_dateLabel setFont:[UIFont systemFontOfSize:12.0f]];
    }
    return _dateLabel;
}

- (UILabel *) msgLabel{
    if (_msgLabel == nil) {
        _msgLabel = [[UILabel alloc] init];
        [_msgLabel setTextColor:[UIColor grayColor]];
        [_msgLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }
    return _msgLabel;
}

-(UIImageView *)redMarkView{
    if(_redMarkView == nil){
        _redMarkView = [[UIImageView alloc] init];
        [_redMarkView setImage:[UIImage imageNamed:@"msg_red_mark"]];
        _redMarkView.layer.masksToBounds = YES;
        _redMarkView.layer.cornerRadius = 12.0f;
        [_redMarkView addSubview:self.redMark];
    }
    return _redMarkView;
}

- (UILabel *)redMark{
    if(_redMark == nil){
        _redMark = [[UILabel alloc] init];
        [_redMark setTextColor:[UIColor whiteColor]];
        [_redMark setTextAlignment:NSTextAlignmentCenter];
        _redMark.layer.masksToBounds = YES;
        _redMark.layer.cornerRadius = 12.0f;
        [_redMark setFrame:CGRectMake(0, 0, 24.0f, 24.0f)];
        [_redMark setFont:[UIFont boldSystemFontOfSize:12.0f]];
    }
    return _redMark;
}

@end
