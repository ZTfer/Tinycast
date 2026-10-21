---
kind: logging_system
name: TinyCast 自定义轻量级日志系统
category: logging_system
scope:
    - '**'
source_files:
    - lib/core/utils/logger.dart
    - lib/main.dart
---

## 系统概述
TinyCast 未使用第三方日志框架，而是基于 `dart:io`、`flutter/foundation` 和 `path` 包自行实现了一个轻量级的静态 Logger 工具类，提供控制台输出与文件落盘双通道日志能力。

## 核心实现
- **位置**: `lib/core/utils/logger.dart`
- **级别枚举**: `LogLevel.debug / info / warning / error`
- **默认标签**: `_defaultTag = 'TinyCast'`
- **最小级别控制**: `_minLevel` 在 debug 模式下为 `info`，release 模式为 `warning`，可通过 `setMinLevel()` 动态调整
- **文件日志**: 通过 `initFileLogging({String? logDirPath})` 初始化，默认写入应用支持目录下的 `log/YYYY-MM-DD.log`，支持自定义路径

## 输出格式
每条日志统一格式：`[ISO8601时间戳] [LEVEL] [TAG] 消息`，错误日志额外附带 `Error:` 和 `StackTrace:` 行。调试模式下同时调用 `debugPrint` 输出到控制台；文件写入采用异步追加模式，失败时自动禁用文件日志。

## 初始化与集成
应用入口 `lib/main.dart` 的 `_initializeApp()` 中统一调用 `Logger.initFileLogging()`，在 Isar 数据库和音频服务之后、Supabase 初始化之前执行，确保所有模块启动阶段均可记录日志。

## 使用范围
全项目各层广泛使用，覆盖 core/services、core/providers、data/datasources、data/repositories、data/services 等模块，典型调用如 `Logger.info('...')`、`Logger.error('...', error: e, stackTrace: stackTrace)`，并通过可选 `tag` 参数区分来源。

## 约束与约定
- 无外部依赖，仅使用 Dart/Flutter SDK 内置能力
- 错误日志必须传入 `error` 和 `stackTrace` 参数以便追踪
- 文件日志失败会静默降级（设置 `_fileLoggingEnabled = false`），不影响主流程
- 日志级别在 release 构建下默认过滤掉 debug/info，减少性能开销