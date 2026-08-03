# Tinycast

基于 Flutter 的跨平台播客客户端（Android / iOS / macOS / Windows / Linux）。

## 快速开始

```bash
flutter pub get
flutter run
```

项目编码约定、架构规范与领域文档索引见 [AGENTS.md](AGENTS.md)——这是所有开发者和 AI agent 的根级入口。

## 交付前检查

交付代码前**必须**运行以下命令，确认全部通过后方可提交：

```bash
flutter analyze   # 静态分析，要求零警告
flutter test       # 全量测试
```

### CI 策略

本项目当前**未接入托管 CI**（无 GitHub Actions / GitLab CI 流水线），交付验收以开发者本地手动执行上述两条命令为准。

该取舍为有意保留：项目处于早期迭代阶段，测试套件与多平台构建矩阵尚未完全稳定，强制 CI 门会引入过高维护成本。如未来接入 CI，最小流水线应直接调用 `flutter analyze` 与 `flutter test` 两条命令作为通过条件。
