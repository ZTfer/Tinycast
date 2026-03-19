# 检查清单

## app_router.dart 新增功能
- [ ] openSettingsWindow 方法已创建
- [ ] openSubscribeWindow 方法已创建
- [ ] 窗口创建逻辑正常工作
- [ ] 窗口配置参数已添加
- [ ] 方法注释完整

## sidebar.dart 更新
- [ ] _openSettingsWindow 方法已移除
- [ ] _openSubscribeWindow 方法已移除
- [ ] 设置按钮调用 router.openSettingsWindow
- [ ] 订阅按钮调用 router.openSubscribeWindow
- [ ] desktop_multi_window 导入已移除（如不需要）
- [ ] 组件功能正常工作

## body.dart 更新（可选）
- [ ] app_router.dart 已导入
- [ ] _navigateToPage 方法使用 router.navigateTo
- [ ] AppRoutes 常量已使用
- [ ] switch 语句使用路由常量
- [ ] 页面切换功能正常工作

## 功能测试
- [ ] 设置窗口可以正常打开
- [ ] 订阅窗口可以正常打开
- [ ] 页面导航功能正常
- [ ] 路由参数传递正常
- [ ] 窗口配置正确应用

## 代码质量
- [ ] 代码符合 MVVM 架构
- [ ] 路由逻辑集中管理
- [ ] 代码注释完整
- [ ] 无编译错误
- [ ] 无 lint 警告
