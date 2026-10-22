# Supabase 云服务配置指南

## 概述

TinyCast 使用 Supabase 提供用户认证与云同步能力。Supabase 凭据通过**编译时环境变量**（`String.fromEnvironment`）读取，应用运行时不读取 `.env` 文件。

本地开发时，`run.sh` 负责读取 `.env` 并把其中的值转换成 `--dart-define` 参数传给 `flutter run`。因此 `.env` 只是 `run.sh` 的输入格式，不是应用本身的配置机制。

## 环境变量

### 应用必需变量

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `SUPABASE_URL` | Supabase 项目 URL（必须是完整 URL） | `https://YOUR_PROJECT_ID.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase 匿名密钥（anon public key） | `YOUR_SUPABASE_ANON_KEY` |

### `.env` 中仅供 `run.sh` 使用的变量

| 变量名 | 说明 |
|--------|------|
| `iOS_Device_ID` | iOS 调试设备名或 ID；不填时 `run.sh ios` 使用 `iphone` |
| `Android_Device_ID` | Android 调试设备 ID；`run.sh android` 要求填写有效值 |

这两个设备变量不会传给应用，只影响 `run.sh` 选择 `flutter run -d` 的目标设备。可通过 `flutter devices` 查看可用设备。

### 获取 Supabase 凭据

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 创建或选择项目
3. 进入 Settings → API
4. 复制 `Project URL` 和 `anon public` 密钥

不要使用 `service_role` 密钥：它绕过行级安全（RLS），只能保存在服务端。

## 配置方式

### 方式一：`.env` + `run.sh`（本地开发推荐）

1. 复制配置模板：

   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env`，把两个 Supabase 占位值替换成真实凭据：

   ```dotenv
   SUPABASE_URL=https://<你的项目引用>.supabase.co
   SUPABASE_ANON_KEY=<你的 anon public key>
   ```

   `.env.example` 中的 `https://YOUR_PROJECT_ID.supabase.co` 和
   `YOUR_SUPABASE_ANON_KEY` 会被应用识别为未配置，必须替换。

3. 用脚本启动：

   ```bash
   ./run.sh          # 按当前操作系统选择 macOS / Linux / Windows 桌面端
   ./run.sh ios      # iOS 模拟器或真机
   ./run.sh android  # Android 设备
   ```

   `run.sh` 会先 `source .env`，再执行：

   ```bash
   flutter run -d "$FLUTTER_DEVICE" \
     --dart-define=SUPABASE_URL="$SUPABASE_URL" \
     --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
   ```

**直接运行 `flutter run` 不会读取 `.env`。** 如果不用 `run.sh`，就必须按方式二手动传入 `--dart-define`。

`run.sh` 依赖 Bash。Windows 请在 Git Bash / WSL 中运行，或改用方式二。

### 方式二：直接传 `--dart-define`（构建、发布、CI）

运行：

```bash
flutter run -d macos \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

构建（`--dart-define` 放在具体平台子命令之后）：

```bash
flutter build macos \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

同样适用于 `flutter build windows`、`linux`、`apk`、`ios` 等。

`--dart-define` 是编译期常量，修改后必须重新构建/完整重启；热重载不会生效。

### 环境变量从哪里生效

应用内只有一处配置来源：

```dart
factory AppConfig.fromEnvironment() {
  return AppConfig(
    supabaseUrl: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://YOUR_PROJECT_ID.supabase.co',
    ),
    supabaseAnonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_SUPABASE_ANON_KEY',
    ),
  );
}
```

`run.sh` 把 `.env` 转成 `--dart-define` 后，值最终同样进入
`String.fromEnvironment`。不存在“`.env` 优先于 `--dart-define`”的运行时优先级。

## 占位符与初始化行为

`AppConfig.isPlaceholder` 在以下任一条件成立时返回 `true`：

- `SUPABASE_URL` 等于默认值 `https://YOUR_PROJECT_ID.supabase.co`
- `SUPABASE_ANON_KEY` 等于默认值 `YOUR_SUPABASE_ANON_KEY`
- 任一值为空或仅含空白

启动时 `lib/main.dart` 的 `_initializeApp()` 据此决定是否初始化：

| 情况 | 日志 |
|------|------|
| 凭据有效 | `✅ Supabase 客户端初始化完成` |
| 未配置或仍是占位符 | `ℹ️ Supabase 未配置（使用占位符），跳过初始化` |

跳过初始化不会阻塞应用启动，本地订阅、播放、下载等功能仍可使用；登录与云同步相关入口不可用。

需要确认实际取值时，查看文件日志（位置见
[docs/debugging/download_debug_guide.md](../debugging/download_debug_guide.md#文件日志位置与读取方式)）：

```bash
grep 'Supabase' "<应用支持目录>/log/$(date +%F).log"
```

`run.sh` 启动时也会打印 `📡 Supabase URL: <前 20 个字符>...`，可用来确认脚本读到了 `.env`。

## 安全注意事项

- `.env` 已加入 `.gitignore`，不要强制提交、截图或粘贴到公开渠道。
- `.env` 文件本身不会被打包；但 `run.sh` / `--dart-define` 会把其中的值编译进应用产物。发布构建中的字符串仍可从二进制提取，因此不要把 `service_role` 密钥或任何服务端密钥放进客户端配置。
- `anon public` 密钥按设计可出现在客户端，前提是数据库已启用并正确配置 RLS 策略。
- `.env.example` 只放占位值。提交前确认没有把真实 URL/密钥写进模板。
- 应用会话保存在 `flutter_secure_storage`（`SecureLocalStorage`），存储键包含项目引用（`sb-<projectRef>-auth-token`），不同 Supabase 项目的登录态互不覆盖。

## 代码中的使用

### 初始化

Supabase 在 `_initializeApp()` 中初始化：

- 读取配置：`AppConfig.fromEnvironment()`
- 判断占位符：`AppConfig.isPlaceholder`
- 调用：`SupabaseService().initialize(...)`

### Riverpod Provider

初始化完成后，可在 Riverpod 中获取客户端：

```dart
import 'package:tinycast/core/services/supabase_service.dart';

final client = ref.watch(supabaseClientProvider);
```

### 直接访问

```dart
import 'package:tinycast/core/services/supabase_service.dart';

final client = SupabaseService().client;
```

`SupabaseService().client` 在未初始化时会抛出 `StateError`。只有在确认
`SupabaseService().isInitialized` 为 `true` 后再访问。

## 常见问题

### Q: 启动日志显示 "Supabase 未配置（使用占位符），跳过初始化"

按顺序检查：

1. 是否用 `./run.sh` 启动？直接 `flutter run` 不会读取 `.env`。
2. `.env` 是否位于仓库根目录，且 `run.sh` 能成功 `source`？
3. 两个值是否已替换？模板中的大写占位符会被判定为未配置。
4. 使用 `--dart-define` 时，变量名大小写是否正确（必须是 `SUPABASE_URL` / `SUPABASE_ANON_KEY`）？
5. 修改编译参数后是否重新构建？热重载不会更新 `--dart-define`。
6. `SUPABASE_URL` 是否为完整 URL（如 `https://xxxx.supabase.co`），而不是只有项目引用？

### Q: `.env` 会被提交吗？

不会。`.env` 在 `.gitignore` 中。可用以下命令确认：

```bash
git check-ignore -v .env
```

如果该命令无输出，说明忽略规则被改动，需要先修复再继续开发。

### Q: 如何切换不同的 Supabase 环境？

为每个环境准备独立文件（如 `.env.dev`、`.env.staging`），通过复制切换：

```bash
cp .env.dev .env
./run.sh
```

或直接传参，不经过 `run.sh`：

```bash
flutter run -d macos \
  --dart-define=SUPABASE_URL="$DEV_SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$DEV_SUPABASE_ANON_KEY"
```

不要修改 `lib/main.dart` 去运行时加载 `.env`；项目没有引入
`flutter_dotenv`，发布包也不应携带可变的配置文件。

### Q: 修改 `.env` 后应用仍使用旧配置？

`--dart-define` 是编译期常量。停止应用后重新执行 `./run.sh`（必要时先
`flutter clean`）再验证。

### Q: Windows 上 `./run.sh` 无法执行？

`run.sh` 是 Bash 脚本。请在 Git Bash / WSL 中运行，或使用方式二的
`flutter run --dart-define=...`。

## 相关文件

| 文件 | 说明 |
|------|------|
| `lib/main.dart` | `AppConfig.fromEnvironment()`、`isPlaceholder` 与启动初始化 |
| `lib/core/services/supabase_service.dart` | Supabase 客户端初始化、`supabaseClientProvider` |
| `lib/core/services/secure_local_storage.dart` | Supabase 会话的安全存储与旧数据迁移 |
| `run.sh` | 本地调试脚本：读取 `.env` 并注入 `--dart-define` |
| `.env.example` | 本地配置模板（仅占位值） |
| `pubspec.yaml` | `supabase_flutter`、`flutter_secure_storage` 依赖 |
