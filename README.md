# Tinycast

基于 Flutter 的跨平台播客客户端（Android / iOS / macOS / Windows / Linux）。

## 快速开始

```bash
flutter pub get

# 需要登录 / 云同步时：复制模板并填入 Supabase 凭据
cp .env.example .env
./run.sh
```

`./run.sh` 会读取 `.env` 并注入 `--dart-define`；直接执行 `flutter run`
不会读取 `.env`。不配置 Supabase 时也可以 `flutter run`，应用会跳过云服务初始化，
本地订阅、播放与下载功能仍可使用。完整说明见
[docs/supabase_setup.md](docs/supabase_setup.md)。

项目编码约定、架构规范与领域文档索引见 [AGENTS.md](AGENTS.md)——这是所有开发者和 AI agent 的根级入口。

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
