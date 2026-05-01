# Tasks

- [x] Task 1: 创建 Supabase 认证服务
  - [x] SubTask 1.1: 创建 `lib/core/services/supabase_auth_service.dart`
  - [x] SubTask 1.2: 实现 Google OAuth 登录方法 `signInWithGoogle()`
  - [x] SubTask 1.3: 实现登出方法 `signOut()`
  - [x] SubTask 1.4: 实现获取当前用户方法 `getCurrentUser()`

- [x] Task 2: 创建认证状态 Riverpod Provider
  - [x] SubTask 2.1: 创建 `lib/core/providers/auth_provider.dart`
  - [x] SubTask 2.2: 实现 `authStateProvider` 监听 Supabase 认证状态变化
  - [x] SubTask 2.3: 实现 `currentUserProvider` 提供当前用户信息

- [x] Task 3: 修改 CloudSyncSettings 实现条件渲染
  - [x] SubTask 3.1: 引入认证状态 Provider
  - [x] SubTask 3.2: 根据登录状态显示 `CloudLoginInfo + SocialLoginButtonGroup` 或 `LoginSuccessPage`

- [x] Task 4: 实现 Google 登录按钮功能
  - [x] SubTask 4.1: 修改 `GoogleLoginButton` 调用认证服务登录方法
  - [x] SubTask 4.2: 处理登录错误情况

- [x] Task 5: 完善 LoginSuccessPage 展示用户信息
  - [x] SubTask 5.1: 从 `currentUserProvider` 获取用户数据
  - [x] SubTask 5.2: 展示用户邮箱、显示名称等信息
  - [x] SubTask 5.3: 添加登出按钮

- [x] Task 6: 测试验证
  - [x] SubTask 6.1: 验证 Google 登录流程正常工作
  - [x] SubTask 6.2: 验证登录状态切换 UI 正常更新
  - [x] SubTask 6.3: 验证登出功能正常

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 1]
- [Task 5] depends on [Task 2]
- [Task 6] depends on [Task 3, Task 4, Task 5]
