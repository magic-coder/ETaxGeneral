/************************************************************
 Class    : MapListViewCell.m
 Describe : 自定义地图机构列表Cell
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MapListViewCell.h"
#import "MapListModel.h"

@interface MapListViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, assign) float space;
@property (nonatomic, assign) float imageWH;
@property (nonatomic, assign) float fontSize;

@end

@implementation MapListViewCell

#pragma mark - 初始化cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _space = 10.0f;
        _imageWH = 20.0f;
        _fontSize = 15.0f;
        
        [self addSubview:self.logoImageView];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if(_model.isExpand){
        switch (_model.level) {
            case 0: {
                self.logoImageView.image = [UIImage imageNamed:@"map_group"];
                
                [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(_imageWH, _imageWH));
                    make.centerY.equalTo(self);
                    make.left.equalTo(self).with.offset(_space);
                }];
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).with.offset(5);
                    make.bottom.equalTo(self).with.offset(-5);
                    make.left.equalTo(self.logoImageView.mas_right).with.offset(_space);
                    make.right.equalTo(self).with.offset(-_space);
                }];
                break;
            }
            case 1: {
                self.logoImageView.image = [UIImage imageNamed:@"map_station"];
                
                [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(_imageWH, _imageWH));
                    make.centerY.equalTo(self);
                    make.left.equalTo(self).with.offset(_space*2+_imageWH);
                }];
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).with.offset(5);
                    make.bottom.equalTo(self).with.offset(-5);
                    make.left.equalTo(self.logoImageView.mas_right).with.offset(_space);
                    make.right.equalTo(self).with.offset(-_space);
                }];
                break;
            }
            case 2: {
                self.logoImageView.image = [UIImage imageNamed:@"map_institute"];
                
                [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(_imageWH, _imageWH));
                    make.centerY.equalTo(self);
                    make.left.equalTo(self).with.offset(_space*3+_imageWH*2);
                }];
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).with.offset(5);
                    make.bottom.equalTo(self).with.offset(-5);
                    make.left.equalTo(self.logoImageView.mas_right).with.offset(_space);
                    make.right.equalTo(self).with.offset(-_space);
                }];
                break;
            }
            default:
                break;
        }
    }
    
}

#pragma mark - 重写Setter、Getter方法
- (void)setModel:(MapListModel *)model{
    _model = model;
    
    if(model.name){
        self.nameLabel.text = model.name;
    }
    
    [self layoutSubviews];
}

-(UIImageView *)logoImageView{
    if(_logoImageView == nil){
        _logoImageView = [[UIImageView alloc] init];
    }
    return _logoImageView;
}

- (UILabel *)nameLabel{
    if(_nameLabel == nil){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 0;
        _nameLabel.font = [UIFont systemFontOfSize:_fontSize];
    }
    return _nameLabel;
}

@end
