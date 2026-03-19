# 检查清单

## app_router.dart 新增功能

- [x] openSettingsWindow 方法已创建
- [x] openSubscribeWindow 方法已创建
- [x] 窗口创建逻辑正常工作
- [x] 窗口配置参数已添加
- [x] 方法注释完整

## sidebar.dart 更新

- [x] _openSettingsWindow 方法已移除
- [x] _openSubscribeWindow 方法已移除
- [x] 设置按钮调用 router.openSettingsWindow
- [x] 订阅按钮调用 router.openSubscribeWindow
- [x] desktop_multi_window 导入已移除（如不需要）
- [x] 组件功能正常工作

## body.dart 更新（可选）

- [x] app_router.dart 已导入
- [x] _navigateToPage 方法使用 router.navigateTo
- [x] AppRoutes 常量已使用
- [x] switch 语句使用路由常量
- [x] 页面切换功能正常工作

## 功能测试

- [x] 设置窗口可以正常打开
- [x] 订阅窗口可以正常打开
- [x] 页面导航功能正常工作
- [x] 路由参数传递正常
- [x] 窗口配置正确应用

## 代码质量

- [x] 代码符合 MVVM 架构
- [x] 路由逻辑集中管理
- [x] 代码注释完整
- [x] 无编译错误
- [x] 无 lint 警告
