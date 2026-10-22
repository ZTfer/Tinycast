[English](README.md) | [简体中文](README.zh-CN.md)

# Tinycast

基于 Flutter 的跨平台播客客户端，支持 Android、iOS、macOS、Windows 和 Linux。

## 功能特性

- **订阅**：通过 RSS 地址订阅并预览、选择剧集，支持 OPML 文件导入；已订阅播客的 Feed 可按设定间隔定时刷新。
- **播放**：后台播放与锁屏控制，支持 0.5×–2.0× 倍速、自定义快进/快退时长、连续播放、睡眠定时和播放队列。
- **离线下载**：单集、批量或按播客下载，支持暂停、恢复、取消与断点续传；可配置自动下载策略，并按类型、播客或保留数量清理缓存。
- **内容管理**：本地内容搜索、收藏、播放历史、搜索历史和已下载列表。
- **云同步**：使用 Supabase 登录后，订阅、播放历史、收藏和播放队列在多设备间增量同步。
- **主题**：HOCON 配置驱动的自定义设计系统，跟随系统亮色/暗色模式，不使用 Material `ThemeData`。

## 技术栈

Flutter + Riverpod 3 + Isar。音频播放使用 `just_audio` 与 `audio_service`，网络请求使用 Dio，云同步基于 Supabase。导航统一走项目自定义的 `AppRouter`，主题由 `assets/themes/*.conf` 在启动时加载。

## 快速开始

环境要求：Flutter，Dart SDK `^3.9.2`。

```bash
flutter pub get

# 需要登录 / 云同步时：复制模板并填入 Supabase 凭据
cp .env.example .env
./run.sh
```

`./run.sh` 会读取 `.env` 并注入 `--dart-define`，默认在当前桌面平台启动。传入平台参数可改为 iOS 或 Android：

```bash
./run.sh ios
./run.sh android
```

iOS / Android 的目标设备取自 `.env` 中的 `iOS_Device_ID` 和 `Android_Device_ID`，可先用 `flutter devices` 查看可用设备。

直接执行 `flutter run` 不会读取 `.env`。不配置 Supabase 时也可以 `flutter run`，应用会跳过云服务初始化，本地订阅、播放与下载功能仍可使用。完整说明见 [docs/supabase_setup.md](docs/supabase_setup.md)。

## 项目结构

```text
lib/
├── core/           # 路由、主题、认证、同步、刷新调度与日志等基础能力
├── data/           # Isar 数据库、数据源、模型、仓储实现、下载与 RSS 服务
├── domain/         # 实体、仓储接口与用例
├── presentation/   # 页面、通用组件与 Riverpod providers
├── main.dart       # 应用入口与多窗口启动分发
├── multi_window.dart
└── window_utils.dart
assets/themes/      # colors.conf / typography.conf / styles.conf
docs/               # 数据库、同步、下载、主题等专题文档
test/               # 单元测试、Widget 测试与数据源测试
```

修改 Isar Collection 定义后，需要重新生成代码：

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 文档

- [AGENTS.md](AGENTS.md)：编码约定、架构规范与完整文档索引，所有开发者和 AI agent 的根级入口
- [docs/database.md](docs/database.md)：Isar Collection 定义、关联关系与代码生成
- [docs/supabase_setup.md](docs/supabase_setup.md)：Supabase 凭据配置与初始化排查
- [docs/sync_debug_guide.md](docs/sync_debug_guide.md)：云同步触发条件、日志与排查路径
- [docs/audio_download_usage.md](docs/audio_download_usage.md)：下载与缓存清理 API
- [docs/theme/overview.md](docs/theme/overview.md)：HOCON 主题系统的加载流程与使用方式
- [docs/PLATFORM_PERMISSIONS.md](docs/PLATFORM_PERMISSIONS.md)：各平台权限、沙盒与文件访问说明

## 交付前检查

交付代码前**必须**运行以下命令，确认全部通过后方可提交：

```bash
flutter analyze   # 静态分析，要求零警告
flutter test       # 全量测试
```

通过标准（预期输出）：

- `flutter analyze`：末行 `No issues found!`，退出码 `0`；出现任何 issue 条目即未通过
- `flutter test`：末行 `All tests passed!`，退出码 `0`；出现 `Some tests failed.` 即未通过

AI agent 会话的收尾交付门（必须实际运行并把结果记入交付总结）见 [AGENTS.md](AGENTS.md#交付前检查)。

### CI 策略

本项目当前**未接入托管 CI**（无 GitHub Actions / GitLab CI 流水线），交付验收以开发者本地手动执行上述两条命令为准。

该取舍为有意保留：项目处于早期迭代阶段，测试套件与多平台构建矩阵尚未完全稳定，强制 CI 门会引入过高维护成本。如未来接入 CI，最小流水线应直接调用 `flutter analyze` 与 `flutter test` 两条命令作为通过条件。
