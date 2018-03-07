/************************************************************
 Class    : UINavigationBar+YZ.m
 Describe : 自定义UINavigationBar的扩展类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-10-26
 LastDate : 2018-03-06
 Version  : 2.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "UINavigationBar+YZ.h"

@implementation UINavigationBar (YZ)

// version 1.0：封装导航栏自定义方法（废弃）
/*
static char overlayKey;

- (UIView *)overlay
{
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setOverlay:(UIView *)overlay
{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)yz_setBackgroundColor:(UIColor *)backgroundColor
{
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + HEIGHT_STATUS)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;    // Should not set `UIViewAutoresizingFlexibleHeight`
        [[self.subviews firstObject] insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}

- (void)yz_setTranslationY:(CGFloat)translationY
{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)yz_setElementsAlpha:(CGFloat)alpha
{
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
        }
        if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")]) {
            obj.alpha = alpha;
        }
    }];
}

- (void)yz_reset
{
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}
*/

// version 2.0：封装导航栏自定义方法
- (void)yz_initialize {
    UIImageView *shadowImg = [self findNavLineImageViewOn:self];
    shadowImg.hidden = YES;
    self.translucent = YES;
}

- (void)yz_changeColor:(UIColor *)color WithScrollView:(UIScrollView *)scrollView AndValue:(CGFloat)value {
    if (scrollView.contentOffset.y < 0) {
        //下拉时导航栏隐藏
        self.hidden = YES;
    }else {
        self.hidden = NO;
        //计算透明度
        CGFloat alpha = scrollView.contentOffset.y /90 >1.0f ? 1:scrollView.contentOffset.y/90;
        //设置一个颜色并转化为图片
        UIImage *image = [UIImage imageWithColor:[color colorWithAlphaComponent:alpha]];
        if(alpha == 1){
            self.translucent = NO;
        }else{
            self.translucent = YES;
        }
        [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)yz_reset {
    UIImageView *shadowImg = [self findNavLineImageViewOn:self];
    shadowImg.hidden = NO;
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

/**
 * 寻找导航栏下的横线（私有方法）
 */
- (UIImageView *)findNavLineImageViewOn:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findNavLineImageViewOn:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
