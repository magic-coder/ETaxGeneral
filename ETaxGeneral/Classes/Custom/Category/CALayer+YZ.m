/************************************************************
 Class    : CALayer+YZ.m
 Describe : 自定义CALayer的扩展类（扩展摇动动画效果）
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-20
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "CALayer+YZ.h"

@implementation CALayer (YZ)

#pragma mark - 摇动动画效果
- (void)shake {
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat s = 5;
    kfa.values = @[@(-s),@(0),@(s),@(0),@(-s),@(0),@(s),@(0)];
    kfa.duration = 0.3f;            // 时长
    kfa.repeatCount = 2;            // 重复
    kfa.removedOnCompletion = YES;  // 移除
    [self addAnimation:kfa forKey:@"shake"];
}

@end
