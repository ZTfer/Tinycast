# Checklist

- [ ] `lib/core/services/supabase_auth_service.dart` 存在且包含 `signInWithGoogle()`、`signOut()`、`getCurrentUser()` 方法
- [ ] `lib/core/providers/auth_provider.dart` 存在且包含 `authStateProvider` 和 `currentUserProvider`
- [ ] `CloudSyncSettings` 根据认证状态条件渲染：未登录时显示登录按钮，已登录时显示用户信息
- [ ] `GoogleLoginButton` 点击后调用 Supabase Google OAuth 登录
- [ ] `LoginSuccessPage` 展示真实用户信息（邮箱、显示名称等）
- [ ] `LoginSuccessPage` 包含登出按钮，点击后调用 `signOut()`
- [ ] Google 登录失败时有适当的错误提示
- [ ] 代码运行无编译错误
- [ ] 登录状态切换时 UI 响应正确
