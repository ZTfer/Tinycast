---
kind: error_handling
name: TinyCast 错误处理体系：统一异常类型与分层处理器
category: error_handling
scope:
    - '**'
source_files:
    - lib/core/utils/app_exception.dart
    - lib/core/utils/error_handler.dart
    - lib/core/utils/network_error_handler.dart
    - lib/core/utils/parse_error_handler.dart
    - lib/core/utils/storage_error_handler.dart
    - lib/core/utils/logger.dart
    - lib/presentation/widgets/common/error_dialog.dart
    - lib/presentation/widgets/common/error_toast.dart
---

## 系统概述

TinyCast 采用基于 Clean Architecture 的分层错误处理体系，通过统一的 `AppException` 异常类型和专门的领域错误处理器，将底层技术异常（网络、存储、解析）转换为应用级语义化错误，并在展示层提供一致的 UI 反馈。

## 核心异常模型

**统一异常类型** (`lib/core/utils/app_exception.dart`)：
- `ExceptionType` 枚举定义六类异常：network、storage、authentication、validation、permission、unknown
- `AppException` 类包含 message、type、statusCode、originalError、stackTrace 字段
- 提供工厂方法如 `AppException.network()`、`AppException.storage()` 等创建特定类型异常
- 所有业务异常均通过此类型向上层传播

## 分层错误处理器

**通用错误处理器** (`lib/core/utils/error_handler.dart`)：
- `ErrorHandler.handleError<T>()` 包装异步操作，自动捕获并转换异常
- 支持注册全局错误处理器回调，实现集中式错误响应
- 内置 Dart 标准异常到 `AppException` 的映射（FormatException→validation、TimeoutException→network、StateError→validation）

**网络错误处理** (`lib/core/utils/network_error_handler.dart`)：
- 专门处理 Dio 网络异常，根据 `DioExceptionType` 分类处理连接超时、发送超时、接收超时、证书验证等场景
- HTTP 状态码映射：400→validation、401→authentication、403→permission、404/5xx→network
- 提供重试机制 `withRetry()` 和超时控制 `withTimeout()`

**解析错误处理** (`lib/core/utils/parse_error_handler.dart`)：
- XML/JSON 解析异常统一转换为 validation 类型异常
- RSS 订阅源 URL 验证、播客数据验证、节目数据验证等专用验证方法
- 安全解析方法 `parseXmlSafely()`、`parseJsonSafely()` 封装异常处理逻辑

**存储错误处理** (`lib/core/utils/storage_error_handler.dart`)：
- 文件系统异常分类：文件不存在(2)、权限不足(13)、磁盘空间不足(28)等
- 文件路径验证、目录创建、文件读写删除的安全封装
- 临时文件清理、文件大小获取等辅助功能

## 日志记录系统

**Logger 工具** (`lib/core/utils/logger.dart`)：
- 支持 debug、info、warning、error 四级日志级别
- 调试模式下输出到控制台，生产模式可启用文件日志
- 自动记录时间戳、日志级别、标签、错误信息和堆栈跟踪
- 文件日志按日期分割，支持动态设置最小日志级别

## 展示层错误反馈

**错误对话框** (`lib/presentation/widgets/common/error_dialog.dart`)：
- `ErrorDialog` 根据 `AppException.type` 显示不同图标、颜色和标题
- 提供 `NetworkErrorDialog`、`ParseErrorDialog`、`StorageErrorDialog` 等专用对话框
- 支持重试和关闭回调，统一错误交互体验

**错误提示** (`lib/presentation/widgets/common/error_toast.dart`)：
- `ErrorToast.showException()` 根据异常类型自动选择合适的 Toast 样式
- 提供成功、警告、错误等多种消息类型
- 使用 `VerticalIconToast` 组件实现美观的错误提示

## 架构设计原则

1. **异常上抛**：底层技术异常在各自处理器中转换为 `AppException`，不直接暴露给上层
2. **语义化分类**：通过 `ExceptionType` 区分错误性质，便于上层针对性处理
3. **集中式处理**：`ErrorHandler` 提供全局错误拦截点，支持插件式错误处理器
4. **用户友好**：展示层根据异常类型提供合适的 UI 反馈，避免技术细节泄露给用户
5. **可观测性**：所有错误通过 Logger 记录，支持文件持久化便于问题排查