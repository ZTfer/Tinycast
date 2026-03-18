# TinyCast 播客应用 MVP 功能总览

## 项目概述
TinyCast 是一个跨平台的播客应用，支持 macOS、Windows、Linux、iOS 和 Android。项目采用 MVVM 架构，使用 Riverpod 进行状态管理，Isar 作为数据库，just_audio + audio_service 处理音频播放。

## 技术栈
- **框架**: Flutter
- **状态管理**: Riverpod
- **数据库**: Isar
- **音频播放**: just_audio + audio_service
- **网络请求**: dio
- **文件路径**: path_provider
- **RSS 解析**: xml
- **图片缓存**: cached_network_image

## 架构设计
项目采用清晰的 MVVM 三层架构：

### Data 层
- **models**: 数据模型（Isar 实体）
- **datasources**: 数据源（本地、远程）
- **repositories**: 仓库实现
- **database**: 数据库相关

### Domain 层
- **entities**: 领域实体
- **repositories**: 仓库接口
- **usecases**: 用例（业务逻辑）

### Presentation 层
- **providers**: Riverpod providers（状态管理）
- **pages**: 页面
- **widgets**: 组件
- **dialogs**: 对话框

### Core 层
- **constants**: 常量
- **theme**: 主题
- **utils**: 工具类
- **router**: 路由

## 功能模块

### 1. 项目架构和文件夹结构整理
**规格文件**: [project-architecture/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/project-architecture/spec.md)

**主要内容**:
- 建立 MVVM 架构分层
- 整理项目文件夹结构
- 添加必要的技术依赖
- 创建基础架构代码

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/project-architecture/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/project-architecture/checklist.md)

### 2. RSS 订阅功能
**规格文件**: [rss-subscription/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/rss-subscription/spec.md)

**主要内容**:
- RSS 订阅源解析
- 播客数据模型和数据库存储
- RSS 订阅界面和交互逻辑
- 订阅验证和错误处理
- 播客列表和详情展示

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/rss-subscription/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/rss-subscription/checklist.md)

### 3. 音频播放功能
**规格文件**: [audio-playback/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/audio-playback/spec.md)

**主要内容**:
- 集成 just_audio 和 audio_service
- 实现音频播放控制（播放、暂停、跳转、速度、音量）
- 实现播放状态管理
- 实现播放进度持久化
- 实现后台播放支持

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/audio-playback/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/audio-playback/checklist.md)

### 4. 下载管理功能
**规格文件**: [download-management/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/download-management/spec.md)

**主要内容**:
- 实现下载管理器
- 实现下载任务队列
- 实现下载进度跟踪
- 实现文件存储管理（使用 path_provider 和 dio）
- 实现下载状态持久化
- 实现自动下载功能

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/download-management/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/download-management/checklist.md)

### 5. 队列管理功能
**规格文件**: [queue-management/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/queue-management/spec.md)

**主要内容**:
- 实现队列数据模型
- 实现队列管理逻辑（添加、移除、重新排序）
- 实现队列 UI 交互
- 实现队列持久化
- 集成播放功能（自动播放下一集）

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/queue-management/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/queue-management/checklist.md)

### 6. 收藏管理功能
**规格文件**: [favorite-management/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/favorite-management/spec.md)

**主要内容**:
- 实现收藏数据模型
- 实现收藏管理逻辑
- 实现收藏 UI 交互
- 实现收藏持久化

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/favorite-management/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/favorite-management/checklist.md)

### 7. 设置管理功能
**规格文件**: [settings-management/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/settings-management/spec.md)

**主要内容**:
- 实现设置数据模型
- 实现播放设置（速度、跳转时间、连续播放）
- 实现下载设置（自动下载、WiFi 限制、仅收藏）
- 实现常规设置（主题、语言）
- 实现设置持久化

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/settings-management/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/settings-management/checklist.md)

### 8. 搜索功能
**规格文件**: [search-functionality/spec.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/search-functionality/spec.md)

**主要内容**:
- 实现搜索服务（集成 Podcast Index API）
- 实现搜索结果展示
- 实现搜索历史管理
- 实现本地资料库搜索
- 实现搜索 UI 交互

**关键文件**:
- [tasks.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/search-functionality/tasks.md)
- [checklist.md](file:///Users/ztfer/Qsync/Playground/Flutter_Playground/tinycast/.trae/specs/search-functionality/checklist.md)

## 开发顺序建议

### 第一阶段：基础架构（必须首先完成）
1. **项目架构和文件夹结构整理** - 建立项目基础
2. **RSS 订阅功能** - 核心功能，其他功能的基础

### 第二阶段：核心功能
3. **音频播放功能** - 播客应用的核心
4. **下载管理功能** - 离线收听支持

### 第三阶段：增强功能
5. **队列管理功能** - 提升用户体验
6. **收藏管理功能** - 快速访问喜欢的内容

### 第四阶段：完善功能
7. **设置管理功能** - 个性化配置
8. **搜索功能** - 发现新内容

## 测试策略

### 单元测试
- 测试数据模型
- 测试数据源
- 测试仓库
- 测试用例
- 测试服务类

### 组件测试
- 测试所有页面
- 测试所有组件
- 测试用户交互

### 集成测试
- 测试完整的用户流程
- 测试跨模块集成
- 测试数据持久化

### 桌面端测试重点
- 文件路径处理（不同平台差异）
- 后台下载逻辑
- 窗口管理
- 多窗口支持

## 数据库设计

### 主要 Collections
1. **Podcast**: 存储播客信息
2. **Episode**: 存储节目信息
3. **QueueItem**: 存储播放队列
4. **Favorite**: 存储收藏
5. **Settings**: 存储用户设置
6. **DownloadTask**: 存储下载任务
7. **SearchHistory**: 存储搜索历史

### 数据库只存路径引用
- 下载的音频文件只存储文件路径
- 实际文件使用 File 类操作
- 使用 path_provider 定位目录

## 文件存储策略

### 路径管理
- 使用 path_provider 获取应用目录
- macOS: `getApplicationSupportDirectory()`
- Windows: `getApplicationSupportDirectory()`
- Linux: `getApplicationSupportDirectory()`
- iOS: `getApplicationSupportDirectory()`
- Android: `getApplicationDocumentsDirectory()`

### 文件组织
```
app_data/
  ├── downloads/        # 下载的音频文件
  ├── cache/           # 缓存文件
  └── database/         # Isar 数据库文件
```

## 性能优化建议

### 图片加载
- 使用 cached_network_image 缓存图片
- 实现图片懒加载
- 优化图片大小

### 列表渲染
- 使用 ListView.builder
- 实现分页加载
- 避免不必要的重建

### 数据库查询
- 配置合适的索引
- 使用查询优化
- 避免频繁查询

### 下载管理
- 限制并发下载数量
- 实现断点续传
- 优化下载队列

## 文档说明

每个功能模块都包含三个文档：

1. **spec.md** - 功能规格说明
   - 为什么需要这个功能
   - 需要做什么变更
   - 详细的需求和场景

2. **tasks.md** - 任务列表
   - 按顺序排列的任务
   - 每个任务的子任务
   - 任务依赖关系

3. **checklist.md** - 检查清单
   - 验证每个功能点
   - 确保实现质量
   - 测试覆盖检查

## 下一步行动

1. **审阅规格文档** - 查看所有功能模块的详细规格
2. **确认技术栈** - 确认依赖和技术选择
3. **开始实施** - 按照建议的开发顺序开始实施
4. **持续验证** - 使用 checklist 验证每个功能的实现

## 注意事项

- **桌面适配**: 尽早引入桌面端测试，特别是文件路径和后台下载逻辑的差异
- **MVVM 架构**: 严格遵循架构分层，保持代码清晰
- **状态管理**: 使用 Riverpod 统一管理应用状态
- **错误处理**: 优雅地处理所有错误，提供友好的用户提示
- **测试覆盖**: 确保每个功能都有完整的测试覆盖
- **性能优化**: 关注应用性能，特别是列表渲染和图片加载
