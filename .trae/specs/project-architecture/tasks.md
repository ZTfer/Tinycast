# 任务列表

- [x] 任务 1：整理项目文件夹结构
  - [x] 子任务 1.1：创建 core 文件夹及子文件夹（constants、theme、utils、router）
  - [x] 子任务 1.2：创建 data 文件夹及子文件夹（models、datasources、repositories、database）
  - [x] 子任务 1.3：创建 domain 文件夹及子文件夹（entities、repositories、usecases）
  - [x] 子任务 1.4：创建 presentation 文件夹及子文件夹（providers、pages、widgets、dialogs）
  - [x] 子任务 1.5：移动现有 UI 文件到 presentation 层

- [x] 任务 2：添加项目依赖
  - [x] 子任务 2.1：添加 Isar 相关依赖
  - [x] 子任务 2.2：添加 Riverpod 相关依赖
  - [x] 子任务 2.3：添加音频播放相关依赖（just_audio、audio_service）
  - [x] 子任务 2.4：添加网络和文件相关依赖（dio、path_provider）
  - [x] 子任务 2.5：添加其他必要依赖（cached_network_image、xml）
  - [x] 子任务 2.6：运行 flutter pub get

- [x] 任务 3：创建核心工具类
  - [x] 子任务 3.1：创建常量类（AppConstants）
  - [x] 子任务 3.2：创建日志工具类（Logger）
  - [x] 子任务 3.3：创建错误处理类（AppException、ErrorHandler）
  - [x] 子任务 3.4：创建文件路径工具类（PathHelper）
  - [x] 子任务 3.5：创建网络工具类（NetworkHelper）

- [x] 任务 4：创建数据库基础架构
  - [x] 子任务 4.1：创建 Isar 数据库初始化类（IsarService）
  - [x] 子任务 4.2：配置 Isar 实例
  - [x] 子任务 4.3：创建数据库版本管理
  - [x] 子任务 4.4：在 main.dart 中初始化数据库

- [x] 任务 5：创建 Riverpod 基础架构
  - [x] 子任务 5.1：创建 Provider 基类
  - [x] 子任务 5.2：创建 StateNotifier 基类
  - [x] 子任务 5.3：创建 Provider 容器

- [x] 任务 6：创建主题配置
  - [x] 子任务 6.1：定义应用主题颜色
  - [x] 子任务 6.2：定义应用字体
  - [x] 子任务 6.3：创建主题配置类

- [x] 任务 7：配置路由
  - [x] 子任务 7.1：定义路由常量
  - [x] 子任务 7.2：创建路由配置
  - [x] 子任务 7.3：实现路由守卫（如需要）

- [x] 任务 8：更新 main.dart
  - [x] 子任务 8.1：配置 ProviderScope
  - [x] 子任务 8.2：初始化数据库
  - [x] 子任务 8.3：配置主题
  - [x] 子任务 8.4：配置路由

- [x] 任务 9：创建基础测试框架
  - [x] 子任务 9.1：配置测试依赖
  - [x] 子任务 9.2：创建测试工具类
  - [x] 子任务 9.3：创建 Mock 工厂类

## 任务依赖关系说明

本任务列表中的任务依赖关系如下：

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 1]
- [任务 4] 依赖于 [任务 2]
- [任务 5] 依赖于 [任务 2]
- [任务 6] 依赖于 [任务 1]
- [任务 7] 依赖于 [任务 1]
- [任务 8] 依赖于 [任务 4, 任务 5, 任务 6, 任务 7]
- [任务 9] 依赖于 [任务 1]
