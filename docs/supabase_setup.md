# Supabase 云服务配置指南

## 概述

TinyCast 使用 Supabase 作为云服务提供商，支持用户认证、云同步等功能。

## 环境变量配置

### 必需的环境变量

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `SUPABASE_URL` | Supabase 项目 URL | `https://your-project-id.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase 匿名密钥 | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

### 获取 Supabase 凭据

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 创建或选择你的项目
3. 进入 Settings → API
4. 复制 `Project URL` 和 `anon public` 密钥

### 配置方式

#### 方式一：本地 `.env` 文件（推荐用于开发调试）

1. 复制示例配置模板：
   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env` 文件，填入实际的 Supabase 凭据：
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. 启动应用：
   ```bash
   flutter run
   ```

#### 方式二：编译时环境变量（推荐用于构建发布）

在构建命令中直接传入环境变量：

```bash
flutter build \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

支持的平台：
- `flutter build macos`
- `flutter build windows`
- `flutter build linux`
- `flutter build ios`
- `flutter build android`

## 安全注意事项

### ⚠️ 敏感信息保护

- **`.env` 文件已加入 `.gitignore`**，不会被提交到代码仓库
- **`.env` 不会打包到应用产物中**，防止敏感信息泄露
- 代码优先读取 `.env` 文件，如果不存在则回退到编译时变量

### 环境变量优先级

1. `.env` 文件（开发调试时使用）
2. `--dart-define` 编译参数（构建发布时使用）

### 配置文件模板

示例配置模板位于 `.env.example`，包含占位值供参考。

## 代码中的使用

### 初始化

Supabase 在应用启动时自动初始化（见 `lib/main.dart` 的 `_initializeApp()` 函数）。如果未配置凭据，会自动跳过初始化，不影响其他功能。

### Riverpod Provider

在需要使用 Supabase 的地方，可以通过 Riverpod Provider 获取客户端实例：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/services/supabase_service.dart';

// 在 ConsumerWidget 或 HookWidget 中使用
final client = ref.watch(supabaseClientProvider);
```

### 直接访问

```dart
import 'package:tinycast/core/services/supabase_service.dart';

final client = SupabaseService().client;
```

## 常见问题

### Q: 应用启动时显示 "Supabase 未配置，跳过初始化"

**A:** 这说明 Supabase 凭据未正确配置。请检查：
1. `.env` 文件是否存在且格式正确
2. `SUPABASE_URL` 和 `SUPABASE_ANON_KEY` 是否都有值
3. 如果使用 `--dart-define`，确保参数正确传入

### Q: 如何切换不同的 Supabase 环境？

**A:** 创建不同的 `.env` 文件（如 `.env.dev`、`.env.prod`），在启动时指定：

```dart
// 修改 main.dart 中的 dotenv.load 调用
await dotenv.load(fileName: '.env.dev');
```

或者在构建时传入不同的 `--dart-define` 参数。

## 相关文件

| 文件 | 说明 |
|------|------|
| `lib/core/services/supabase_service.dart` | Supabase 客户端服务 |
| `lib/main.dart` | 应用启动和 Supabase 初始化 |
| `.env.example` | 环境变量配置模板 |
| `pubspec.yaml` | `flutter_dotenv` 和 `supabase_flutter` 依赖声明 |
