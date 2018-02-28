/************************************************************
 Class    : BaseScrollView.m
 Describe : 基本的滚动视图，自定义回弹效果
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-30
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "BaseScrollView.h"

@implementation BaseScrollView

// 默认初始化，全屏的视图
- (instancetype)init{
    if(self = [super initWithFrame:FRAME_SCREEN]){
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        //通过width,height，来确定显示的内容的区域的大小。只要其大小超过scrollView自身的大小，就能产生滑动
        CGFloat width = CGRectGetWidth(FRAME_SCREEN);
        CGFloat height = CGRectGetHeight(FRAME_SCREEN);
        self.contentSize = CGSizeMake(width, height);
        //通过设置pagingEnabled这个属性，可以控制scrollView的子视图按整屏翻动，默认为NO
        self.pagingEnabled = NO;
        //通过修改contenOffset这个属性，让区域内容(子视图)按照偏移量的大小来进行显示。
        self.contentOffset = CGPointMake(CGRectGetWidth(self.bounds)*0, 0);
        //滑动视图的边界回弹效果，默认为YES.表示开启动画，设置为NO时，当滑动到边缘就是无效果
        self.bounces = YES;
        //设置横向滑动的指示器是否显示,默认也是为显示
        self.showsHorizontalScrollIndicator = NO;
        //设置纵向滑动的指示器的显示，默认也是为显示
        self.showsVerticalScrollIndicator = NO;
        //滑动方向的锁定，默认为NO,不锁定的
        self.directionalLockEnabled = YES;
        
        //默认是NO，当设置为YES时，可以运行content小于scrollView边界的回弹效果
        self.alwaysBounceHorizontal = NO; // 水平方向滑动
        self.alwaysBounceVertical = YES;  // 垂直方向滑动
        //设置tag值 作用是如果和UIPageControl搭配使用 用Tag值来相互关联
        //self.tag = 1;
    }
    
    return self;
}

// 根据需要传入frame进行创建视图
- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        //通过width,height，来确定显示的内容的区域的大小。只要其大小超过scrollView自身的大小，就能产生滑动
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        self.contentSize = CGSizeMake(width, height);
        
        //通过设置pagingEnabled这个属性，可以控制scrollView的子视图按整屏翻动，默认为NO
        self.pagingEnabled = NO;
        //通过修改contenOffset这个属性，让区域内容(子视图)按照偏移量的大小来进行显示。
        self.contentOffset = CGPointMake(CGRectGetWidth(self.bounds)*0, 0);
        //滑动视图的边界回弹效果，默认为YES.表示开启动画，设置为NO时，当滑动到边缘就是无效果
        self.bounces = YES;
        //设置横向滑动的指示器是否显示,默认也是为显示
        self.showsHorizontalScrollIndicator = NO;
        //设置纵向滑动的指示器的显示，默认也是为显示
        self.showsVerticalScrollIndicator = NO;
        //滑动方向的锁定，默认为NO,不锁定的
        self.directionalLockEnabled = YES;
        
        //默认是NO，当设置为YES时，可以运行content小于scrollView边界的回弹效果
        self.alwaysBounceHorizontal = NO; // 水平方向滑动
        self.alwaysBounceVertical = YES;  // 垂直方向滑动
        //设置tag值 作用是如果和UIPageControl搭配使用 用Tag值来相互关联
        //self.tag = 1;
    }
    
    return self;
}

@end
