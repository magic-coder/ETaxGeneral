/************************************************************
 Class    : YZTouchID.h
 Describe : 自定义指纹识别类
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-17
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import <LocalAuthentication/LocalAuthentication.h>

/**
 *  TouchID 状态
 */
typedef NS_ENUM(NSUInteger, YZTouchIDState){
    
    /**
     *  当前设备不支持TouchID
     */
    YZTouchIDStateNotSupport = 0,
    /**
     *  TouchID 验证成功
     */
    YZTouchIDStateSuccess = 1,
    
    /**
     *  TouchID 验证失败
     */
    YZTouchIDStateFail = 2,
    /**
     *  TouchID 被用户手动取消
     */
    YZTouchIDStateUserCancel = 3,
    /**
     *  用户不使用TouchID,选择手动输入密码
     */
    YZTouchIDStateInputPassword = 4,
    /**
     *  TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    YZTouchIDStateSystemCancel = 5,
    /**
     *  TouchID 无法启动,因为用户没有设置密码
     */
    YZTouchIDStatePasswordNotSet = 6,
    /**
     *  TouchID 无法启动,因为用户没有设置TouchID
     */
    YZTouchIDStateTouchIDNotSet = 7,
    /**
     *  TouchID 无效
     */
    YZTouchIDStateTouchIDNotAvailable = 8,
    /**
     *  TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)
     */
    YZTouchIDStateTouchIDLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    YZTouchIDStateAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    YZTouchIDStateInvalidContext = 11,
    /**
     *  系统版本不支持TouchID (必须高于iOS 8.0才能使用)
     */
    YZTouchIDStateVersionNotSupport = 12
};



@interface YZTouchID : LAContext

typedef void (^StateBlock)(YZTouchIDState state,NSError *error);


/**
 启动TouchID进行验证
 
 @param desc Touch显示的描述
 @param block 回调状态的block
 */

-(void)td_showTouchIDWithDescribe:(NSString *)desc BlockState:(StateBlock)block;


@end
