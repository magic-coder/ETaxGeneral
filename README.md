# ETaxGeneral（E税通）IOS移动端项目重构版

[![Release](https://img.shields.io/badge/release-2.0.0-brightgreen.svg)](https://github.com/micyo202/ETaxGeneral)
[![support](https://img.shields.io/badge/support-ios10+-yellow.svg)](https://github.com/micyo202/ETaxGeneral)
[![Since](https://img.shields.io/badge/since-2017-blue.svg)](https://github.com/micyo202/ETaxGeneral)
[![Device](https://img.shields.io/badge/device-iPhone&iPad-red.svg)](https://github.com/micyo202/ETaxGeneral)
[![GitHub stars](https://img.shields.io/github/stars/micyo202/ETaxGeneral.svg?style=social&label=Stars)](https://github.com/micyo202/ETaxGeneral)
[![GitHub forks](https://img.shields.io/github/forks/micyo202/ETaxGeneral.svg?style=social&label=Fork)](https://github.com/micyo202/ETaxGeneral)

### 一、简介

项目Devices采用Universal，同时支持**iPhone & iPad**，技术重新选型，UI渲染更细腻，代码清晰简洁，兼容IOS11，适配iPhoneX，便于后期维护<br>
主界面框架模式采用目前主流的**UINavigationController**与**UITabBarController**整合模式（既：导航控制器与选项卡整合模式）
整屏切换效果，集成了全新的动画效果，视觉感强烈。

### 二、开发环境

* MacOS High Sierra
* IOS10+
* Xcode 9.0+

### 三、项目结构

```lua
ETaxGeneral -- 根目录
├── Classes -- 类路径
|    ├── News -- 首页税闻模块
|    ├── App -- 应用模块
|    ├── Map -- 地图模块
|    ├── Msg -- 消息模块
|    ├── Mine -- 我的模块
|    ├── Login -- 登录模块
|    ├── Base -- 基础模块
|    ├── Main -- 主视图模块
|    ├── Gesture -- 手势密码
|    ├── TouchID -- TouchID/FaceID解锁识别模块
|    ├── Custom -- 自定义类
|    ├── Global -- 全局类
├── Expands -- 扩展路径
├── Plugins -- 插件路径
├── Resources -- 资源文件
├── Supporting Files -- 支持文件
```
### 一、其他
##### 1.系统使用的色彩值
* 红 #E8453C RGB(232,69,60)
* 橙 #F6BC2D RGB(246,188,45)
* 蓝 #4587F7 RGB(69,135,247)
* 绿 #3AA756 RGB(58,167,86)

##### 2.自己扩展的类库

名称 | 版本号 | 描述 | 网址
--- | --- | --- | ---
YZTouchID | 1.0.0 | 指纹、面部识别认证 | [https://github.com/micyo202/YZAuthID](https://github.com/micyo202/YZAuthID)
YZCycleScrollView | 1.0.0 | 循环轮播图 | [https://github.com/micyo202/YZCycleScrollView](https://github.com/micyo202/YZCycleScrollView)
YZBottomSelectView | 1.0.1 | 底部选择框 | [https://github.com/micyo202/YZBottomSelectView](https://github.com/micyo202/YZBottomSelectView)

##### 3.使用到的第三方库

名称 | 版本号 | 描述 | 网址
--- | --- | --- | ---
Sangfor | 7.5.2.77860 | VPN服务 | [https://pan.baidu.com/s/1i4OvN1b](https://pan.baidu.com/s/1i4OvN1b)
Masonry | 1.1.0 | 自适应布局 | [https://github.com/SnapKit/Masonry](https://github.com/SnapKit/Masonry)
YYModel | 1.0.4 | 模型转换 | [https://github.com/ibireme/YYModel](https://github.com/ibireme/YYModel)
MJRefresh | 3.1.15 | 刷新组件 | [https://github.com/CoderMJLee/MJRefresh](https://github.com/CoderMJLee/MJRefresh)
FCAlertView | 1.4.0 | 提示对话框 | [https://github.com/nimati/FCAlertView](https://github.com/nimati/FCAlertView)
SAMKeychain | 1.5.2 | Keychain安全存储 | [https://github.com/soffes/SAMKeychain](https://github.com/soffes/SAMKeychain)
SDWebImage | 4.2.2 | 网络图片加载 | [https://github.com/rs/SDWebImage](https://github.com/rs/SDWebImage)
AFNetworking | 3.1.0 | 网络请求 | [https://github.com/AFNetworking/AFNetworking](https://github.com/AFNetworking/AFNetworking)
YBPopupMenu | 1.1.0 | 气泡菜单 | [https://github.com/lyb5834/YBPopupMenu](https://github.com/lyb5834/YBPopupMenu)
MBProgressHUD | 1.1.0 | 浮动提示框 | [https://github.com/jdg/MBProgressHUD](https://github.com/jdg/MBProgressHUD)
PCGestureUnlock | 1.0.0 | 手势密码 | [https://github.com/iosdeveloperpanc/PCGestureUnlock](https://github.com/iosdeveloperpanc/PCGestureUnlock)
TTTAttributedLabel | 2.0.0 | 富文本标签 | [https://github.com/TTTAttributedLabel/TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)
UIAlertControllerBlocks | 0.9.2 | 回调提示框 | [https://github.com/ryanmaxwell/UIAlertController-Blocks](https://github.com/ryanmaxwell/UIAlertController-Blocks)
YALSunnyRefreshControll | 1.0.0 | 刷新动画 | [https://github.com/Yalantis/Pull-to-Refresh.Rentals-iOS](https://github.com/Yalantis/Pull-to-Refresh.Rentals-iOS)****