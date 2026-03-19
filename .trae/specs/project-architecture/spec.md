# 项目架构和文件夹结构整理 Spec

## 为什么

当前项目缺乏清晰的架构分层和文件夹组织，需要建立符合 MVVM 架构的项目结构，以便于团队协作、代码维护和功能扩展。同时需要引入必要的技术栈依赖。

## 变更内容

- 建立清晰的 MVVM 架构分层（Data、Domain、Presentation）
- 整理项目文件夹结构
- 添加必要的依赖包（Isar、Riverpod、just_audio、audio_service、dio、path_provider 等）
- 创建基础架构代码

## 影响

- 受影响的规格：所有后续功能模块
- 受影响的代码：整个项目结构

## 新增需求

### 需求：项目架构设计

系统应采用 MVVM 架构，分为 Data、Domain、Presentation 三层。

#### 场景：架构分层

- **当**开发者查看项目结构
- **则**应看到清晰的 Data、Domain、Presentation 分层
- **并且**每层职责明确，依赖方向正确

### 需求：文件夹结构

系统应遵循标准的 Flutter 项目文件夹组织方式。

#### 场景：文件夹组织

- **当**开发者浏览项目
- **则**应看到以下文件夹结构：

```text
lib/
  ├── core/              # 核心功能
  │   ├── constants/     # 常量
  │   ├── theme/        # 主题
  │   ├── utils/        # 工具类
  │   └── router/       # 路由
  ├── data/             # 数据层
  │   ├── models/       # 数据模型
  │   ├── datasources/   # 数据源（本地、远程）
  │   ├── repositories/  # 仓库实现
  │   └── database/     # 数据库相关
  ├── domain/           # 领域层
  │   ├── entities/     # 领域实体
  │   ├── repositories/  # 仓库接口
  │   └── usecases/    # 用例
  ├── presentation/      # 表现层
  │   ├── providers/    # Riverpod providers
  │   ├── pages/       # 页面
  │   ├── widgets/     # 组件
  │   └── dialogs/     # 对话框
  └── main.dart
```

### 需求：依赖管理

系统应使用正确的依赖包。

#### 场景：添加依赖

- **当**查看 pubspec.yaml
- **则**应包含以下依赖：
  - isar: ^3.1.0+1（数据库）
  - isar_flutter_libs: ^3.1.0+1（数据库）
  - riverpod: ^2.5.1（状态管理）
  - flutter_riverpod: ^2.5.1（状态管理）
  - just_audio: ^0.9.40（音频播放）
  - audio_service: ^0.19.0（音频服务）
  - dio: ^5.7.0（网络请求）
  - path_provider: ^2.1.4（文件路径）
  - cached_network_image: ^3.4.1（图片缓存）
  - xml: ^6.6.2（RSS 解析）

### 需求：数据库初始化

系统应在应用启动时初始化 Isar 数据库。

#### 场景：数据库初始化

- **当**应用启动
- **则**应初始化 Isar 数据库
- **并且**创建所有必要的 collection
- **并且**处理数据库版本迁移

### 需求：错误处理基础架构

系统应提供统一的错误处理机制。

#### 场景：错误处理

- **当**发生错误
- **则**应通过统一的错误处理器处理
- **并且**向用户显示友好的错误消息

### 需求：日志系统

系统应提供日志记录功能。

#### 场景：日志记录

- **当**需要记录日志
- **则**应使用统一的日志工具
- **并且**支持不同日志级别（debug、info、warning、error）

## 修改的需求

无

## 移除的需求

无
