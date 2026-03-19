# 任务列表

- [ ] 任务 1：在 app_router.dart 中添加新窗口打开方法
  - [ ] 子任务 1.1：添加 openSettingsWindow 方法
  - [ ] 子任务 1.2：添加 openSubscribeWindow 方法
  - [ ] 子任务 1.3：使用 desktop_multi_window 创建窗口
  - [ ] 子任务 1.4：添加窗口配置参数

- [ ] 任务 2：更新 sidebar.dart 使用 router 的新窗口方法
  - [ ] 子任务 2.1：移除 _openSettingsWindow 方法
  - [ ] 子任务 2.2：移除 _openSubscribeWindow 方法
  - [ ] 子任务 2.3：更新设置按钮的 onPressed 调用 router
  - [ ] 子任务 2.4：更新订阅按钮的 onPressed 调用 router
  - [ ] 子任务 2.5：移除 desktop_multi_window 导入（如果不再需要）

- [ ] 任务 3：更新 body.dart 使用路由常量（可选）
  - [ ] 子任务 3.1：导入 app_router.dart
  - [ ] 子任务 3.2：更新 _navigateToPage 方法使用 router.navigateTo
  - [ ] 子任务 3.3：使用 AppRoutes 常量替代字符串
  - [ ] 子任务 3.4：更新 switch 语句使用路由常量

- [ ] 任务 4：测试路由功能
  - [ ] 子任务 4.1：测试设置窗口打开
  - [ ] 子任务 4.2：测试订阅窗口打开
  - [ ] 子任务 4.3：测试页面导航
  - [ ] 子任务 4.4：测试路由参数传递

# 任务依赖关系
- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 1]
- [任务 4] 依赖于 [任务 1, 任务 2, 任务 3]
