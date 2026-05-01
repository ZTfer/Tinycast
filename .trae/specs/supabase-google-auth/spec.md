# Supabase Google 登录功能

## Why
当前应用的云同步设置页面展示了登录按钮，但未实现 Google 登录功能。需要通过 Supabase Auth 实现 Google OAuth 登录，并根据登录状态展示不同的 UI。

## What Changes
- 实现 Google 登录逻辑，调用 Supabase OAuth 接口
- 创建认证状态管理 Provider，监听 Supabase 登录状态变化
- 修改 `CloudSyncSettings` 根据登录状态显示不同内容
- 完善 `LoginSuccessPage` 展示真实用户信息
- 实现 Google 登录按钮的点击回调

## Impact
- Affected specs: cloud-sync-settings, authentication
- Affected code: 
  - `lib/core/services/supabase_auth_service.dart` (新建)
  - `lib/core/providers/auth_provider.dart` (新建)
  - `lib/presentation/features/settings/cloud_sync_settings/cloud_sync_settings.dart`
  - `lib/presentation/features/settings/cloud_sync_settings/login_widgets/login_success_page.dart`
  - `lib/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/google_login_button.dart`

## ADDED Requirements

### Requirement: Supabase 认证服务
系统 SHALL 提供 Supabase Google OAuth 登录功能

#### Scenario: Google 登录成功
- **WHEN** 用户点击 Google 登录按钮
- **THEN** 调用 `SupabaseClient.auth.signInWithOAuth(OAuthProvider.google)`
- **AND** 浏览器打开 Google OAuth 授权页面
- **AND** 授权成功后返回应用，用户状态变为已登录

#### Scenario: Google 登出
- **WHEN** 用户点击登出按钮
- **THEN** 调用 `SupabaseClient.auth.signOut()`
- **AND** 用户状态变为未登录

### Requirement: 认证状态管理
系统 SHALL 提供 Riverpod Provider 用于管理和监听认证状态

#### Scenario: 认证状态变化通知
- **WHEN** Supabase 认证状态变化
- **THEN** Riverpod Provider 自动更新
- **AND** 所有监听该状态的 Widget 自动重建

### Requirement: 登录状态条件渲染
系统 SHALL 根据登录状态展示不同的 UI 内容

#### Scenario: 未登录状态
- **WHEN** 用户未登录
- **THEN** `CloudSyncSettings` 显示 `CloudLoginInfo` 和 `SocialLoginButtonGroup`

#### Scenario: 已登录状态
- **WHEN** 用户已登录
- **THEN** `CloudSyncSettings` 显示 `LoginSuccessPage` 展示用户信息

## MODIFIED Requirements

### Requirement: LoginSuccessPage 展示真实用户数据
**当前**: 使用硬编码的占位文字
**修改为**: 从 Supabase auth.currentUser 获取真实用户信息并展示
