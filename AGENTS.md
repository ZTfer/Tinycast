# AGENTS.md

TinyCast 是基于 Flutter 的跨平台播客客户端（Android / iOS / macOS / Windows / Linux）。本文件是 agent 的根级入口，提供项目约定与领域文档的路由索引。

> 本文件是所有 AI agent 工具的统一入口（AGENTS.md 标准）。`CLAUDE.md` / `GEMINI.md` / `.windsurfrules` 均为指向本文件的 symlink，请勿单独编辑它们。

## 项目约定

项目编码约定以 `.agents/rules/` 为 canonical 内容源，agent 在修改代码前应先读取以下规则：

| 规则文件 | 适用场景 |
|----------|----------|
| [`.agents/rules/ai-rules-for-flutter-and-dart.md`](.agents/rules/ai-rules-for-flutter-and-dart.md) | Flutter/Dart 编码规范：分层架构（Pres/Domain/Data）、Riverpod 状态管理、自定义 AppRouter 导航、Isar 数据访问、`json_serializable` 序列化、自定义主题系统（禁用 Material Design）、命名约定与 SOLID 原则 |
| [`.agents/rules/cross-platform-compatibility.md`](.agents/rules/cross-platform-compatibility.md) | 跨平台兼容性：文件名非法字符（Windows）、路径长度限制、换行符统一（LF）、大小写敏感差异、IDE 临时文件 gitignore、Flutter 多平台构建命令 |
| [`.agents/rules/settings_storage_rules.md`](.agents/rules/settings_storage_rules.md) | 设置存储策略：`shared_preferences` 存普通设置、`flutter_secure_storage` 存敏感凭证、Riverpod 状态管理集成模式、自动下载策略枚举 |

## 关键约束速查

以下为三份规则文件的关键约束摘要，完整细节以 `.agents/rules/` 原文为准（canonical）：

- **设置存储策略**：普通设置（主题/播放/下载/开关枚举）用 `shared_preferences`，复杂设置组转 JSON 存储；敏感凭证（Auth Token、密码、API Key）必须用 `flutter_secure_storage`（iOS Keychain / Android Keystore），严禁存入 `shared_preferences`。
- **状态管理**：全应用使用 Riverpod，根部包裹 `ProviderScope`；设置项必须接入 Notifier + Provider 模式使 UI 实时响应变化，UI 内 `ref.watch` 读状态、`ref.read(xxx.notifier)` 改状态。
- **导航**：统一使用项目自定义 `AppRouter`（`AppRouter.navigateTo(context, AppRoutes.xxx, arguments: ...)`），不使用 go_router 等第三方路由。
- **架构与命名**：Presentation / Domain / Data 分层，遵循 SOLID；类 `PascalCase`、成员 `camelCase`、文件 `snake_case`。
- **数据与序列化**：本地存储用 Isar；API 数据用 `json_serializable`（`FieldRename.snake`）。
- **UI**：自定义设计系统与 HOCON 主题（见 `docs/theme/`），禁用 Material Design（不用 `MaterialApp`/`ThemeData`/`ColorScheme`）。
- **跨平台兼容**：文件名禁止 `: * ? " < > |`，统一 LF 换行，路径 ≤ 260 字符，注意 Linux 大小写敏感差异。

## 项目文档索引

`docs/` 目录存放领域文档与调试手册。按场景直达对应文档：

### 数据库

| 文档 | 适用场景 |
|------|----------|
| [docs/database.md](docs/database.md) | 需要理解本地数据层时查阅：Isar 数据库初始化、7 个 Collection（Podcast/Episode/Favorite/Queue/PlayHistory/SearchHistory/AppSettings）的字段定义与索引、ER 关联关系、Fallback 关联机制（guid/iTunesId 优先级）、`build_runner` 代码生成命令、Isar Inspector 使用、事务与软删除最佳实践 |

### Supabase 配置

| 文档 | 适用场景 |
|------|----------|
| [docs/supabase_setup.md](docs/supabase_setup.md) | 需要配置或排查云同步时查阅：`SUPABASE_URL` 与 `SUPABASE_ANON_KEY` 环境变量配置（`.env` 文件与 `--dart-define` 两种方式）、凭据获取步骤、环境变量优先级、安全注意事项（`.env` 不入库不入包）、Riverpod Provider 用法、初始化失败排查 |

### 平台权限

| 文档 | 适用场景 |
|------|----------|
| [docs/PLATFORM_PERMISSIONS.md](docs/PLATFORM_PERMISSIONS.md) | 需要处理文件访问或打包配置时查阅：iOS（Info.plist）、macOS（DebugProfile/Release Entitlements）、Android（AndroidManifest）、Linux（Snap/Flatpak）、Windows 五平台的沙盒与权限现状、`getApplicationSupportDirectory()` 各平台返回路径、访问沙盒外文件时需添加的权限声明 |

### 下载调试手册

| 文档 | 适用场景 |
|------|----------|
| [docs/audio_download_usage.md](docs/audio_download_usage.md) | 需要调用下载 API 或缓存清理时查阅：`AudioDownloadService` 单个/批量/按播客下载方法、队列状态查询、暂停/恢复/取消控制、下载状态与进度 Stream 监听、`CacheCleanupService` 缓存清理（按类型/按播客/保留最近 N 集/自动清理）、文件存储位置与命名规则 |
| [docs/download_debug_guide.md](docs/download_debug_guide.md) | 下载功能出错时查阅：emoji 日志标识符速查表（📁🎵⬇️📥📊✅❌⚠️🔄 等）、订阅自动下载的日志序列、单个下载流程日志、找不到文件/下载失败/数据库未更新/自动下载未触发四个排查路径、DevTools 与命令行调试方法、文件系统检查命令 |
| [docs/download_queue_debug.md](docs/download_queue_debug.md) | 下载队列不执行时查阅：队列处理缺失日志的根因分析、`_processQueue()` 调用链排查、`canStartNewDownload`/`dequeue`/`maxConcurrent` 状态诊断、episode 未找到/立即失败的处理、手动测试代码片段、macOS 容器路径诊断命令 |
| [docs/uuid_filename_guide.md](docs/uuid_filename_guide.md) | 涉及下载文件命名时查阅：UUID v4 文件命名方案（替代 episodeId）、`downloadedPath` 相对路径存储格式、UUID 生成算法实现、旧文件兼容与迁移说明、安全与隐私考量、Isar Inspector 验证方法 |

### 主题架构文档

| 文档 | 适用场景 |
|------|----------|
| [docs/theme/overview.md](docs/theme/overview.md) | 需要理解主题系统全貌时查阅：HOCON 驱动的设计原则、亮色/暗色双调色板、编译时常量 vs 运行时解析双模式、文件结构（`assets/themes/*.conf` 与 `lib/core/theme/`）、`AppTheme` 统一访问入口、为什么不用 Material `ThemeData` |
| [docs/theme/colors.md](docs/theme/colors.md) | 需要使用或扩展颜色时查阅：`colors.conf` HOCON 配置语法、`#AARRGGBB` 格式说明、6 大调色板分类表（brand/background/gray/label/overlay）、`AppColors` 类的 const 常量与命名规则、直接使用/`AppThemeData`/`AppThemeConfig` 三种使用方式、添加新颜色的完整步骤 |
| [docs/theme/typography.md](docs/theme/typography.md) | 需要使用或扩展文字样式时查阅：`typography.conf` HOCON 配置语法、desktop/tablet/mobile 响应式变体、`AppTextStyles` 类的样式速查表（h1-h3/bodyLarge-Medium-Small/caption/button）、直接使用/`AppThemeData`/`copyWith` 三种使用方式、添加新文字样式的完整步骤 |

## 交付前检查

交付代码前**必须**运行以下命令，确认全部通过后方可提交：

```bash
flutter analyze   # 静态分析，要求零警告
flutter test       # 全量测试
```

### 会话交付门（AI agent 必须执行）

上述检查清单不变；对 AI agent 会话，它是**会话尾部的硬性交付门**，不是知晓即可的指引。agent 在输出最终总结、宣告任务完成之前，必须对本次会话产生的全部真实变更实际运行下面两条命令，并把实际结果记入交付总结——没有运行记录或任一命令未通过，变更不得宣告完成。

**命令 1 —— 静态分析**

```bash
flutter analyze
```

- 预期输出：末行 `No issues found! (ran in Xs)`，退出码 `0`
- 未通过：输出任何 `error •` / `warning •` / `info •` 条目、汇总行 `N issues found.`，或退出码非 `0`

**命令 2 —— 全量测试**

```bash
flutter test
```

- 预期输出：末行 `All tests passed!`，退出码 `0`
- 未通过：汇总行出现 `Some tests failed.`，或退出码非 `0`
- skipped 用例（汇总行的 `~N` 标记）不阻塞交付门，但须在交付总结中注明数量；本次会话新增的 skip 须说明原因

**交付总结必须记录**：两条命令各自的关键结果行与退出码。任一命令未通过时，先修复并重跑至通过；无法当场修复的，如实粘贴失败输出并明确标注交付门未通过，禁止在无验证结果的情况下宣称已修复。

> 人类开发者入口见 [README.md](README.md#交付前检查)，同样写明了该验收路线与预期输出。

### CI 策略

本项目当前**未接入托管 CI**（无 GitHub Actions / GitLab CI 流水线），交付验收以开发者本地手动执行上述两条命令为准。

该取舍为有意保留：项目处于早期迭代阶段，测试套件与多平台构建矩阵尚未完全稳定，强制 CI 门会引入过高维护成本。如未来接入 CI，最小流水线应直接调用 `flutter analyze` 与 `flutter test` 两条命令作为通过条件。
