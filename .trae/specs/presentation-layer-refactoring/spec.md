# Presentation 层模块化重构 Spec

## 为什么

当前 presentation 层的 pages 文件夹混合了所有页面的代码，随着功能增多（下载、搜索、设置、订阅等），pages 文件夹变得非常扁平且庞大，导致查找文件困难，维护成本增加。缺乏功能内聚性，相关代码分散在不同位置，不利于模块的独立开发和维护。

## 变更内容

- 引入"功能模块"概念，创建 `presentation/features/` 目录
- 将 `pages` 下的业务文件夹按功能模块重新组织到 `features` 下
- 将特定功能的 widgets 移动到对应的 feature 文件夹内，提升内聚性
- 将特定功能的 Provider 移动到对应的 feature 文件夹中
- 清理 `core/utils` 中的示例文件和不合适的 UI 组件
- 优化 widgets 的原子设计结构

## 影响

- 受影响的规格：所有涉及 presentation 层的功能模块
- 受影响的代码：
  - `lib/presentation/pages/` 下所有文件
  - `lib/presentation/widgets/` 中的部分组件
  - `lib/presentation/providers/` 中的部分 Provider
  - `lib/core/utils/` 中的 UI 相关工具类
  - 所有导入这些文件的代码

## 新增需求

### 需求：功能模块化结构

系统应按功能模块组织 presentation 层代码，每个功能模块包含该功能相关的页面、组件和状态管理。

#### 场景：功能模块目录结构

- **当**开发者查看 presentation 层结构
- **则**应看到按功能模块划分的目录结构：

```text
lib/presentation/
├── providers/       # 全局或共享的 Provider (如 auth, theme)
├── widgets/         # 全局复用的 UI 组件 (原子设计保持不变)
└── features/        # 按功能模块拆分
    ├── home/        # 首页模块
    ├── search/      # 搜索模块
    ├── library/     # 图书馆模块
    ├── downloads/   # 下载模块
    ├── player/      # 播放器模块
    ├── favorite/    # 收藏模块
    ├── subscribe/   # 订阅模块
    ├── settings/    # 设置模块
    └── queue/       # 队列模块
```

### 需求：功能模块内部结构

每个功能模块应包含该功能相关的所有代码，包括页面、组件和 Provider。

#### 场景：Search Feature 内部结构

- **当**开发者查看 search 功能模块
- **则**应看到以下结构：

```text
lib/presentation/features/search/
├── search_page.dart          # 入口页面
├── search_provider.dart      # 仅用于搜索的 Provider (如果有的话)
└── widgets/                  # 仅用于搜索的组件
    ├── search_input.dart
    ├── search_history_list.dart
    └── search_results_list.dart
```

### 需求：全局组件与局部组件分离

系统应区分全局组件和局部组件，全局组件保持在 `presentation/widgets`，局部组件放在对应的 feature 文件夹内。

#### 场景：全局组件识别

- **当**某个组件在多个功能模块中被使用
- **则**该组件应放在 `presentation/widgets` 中
- **并且**遵循原子设计原则（atoms、molecules）

#### 场景：局部组件识别

- **当**某个组件仅在特定功能模块中使用
- **则**该组件应放在对应 feature 文件夹的 widgets 子目录中
- **例如**：`downloads_control_bar` 应放在 `features/downloads/widgets/` 中

### 需求：Provider 模块化

特定功能的 Provider 应移动到对应的 feature 文件夹中，全局或共享的 Provider 保持在 `presentation/providers` 中。

#### 场景：功能特定 Provider 迁移

- **当**某个 Provider 仅服务于特定功能模块
- **则**该 Provider 应移动到对应 feature 文件夹中
- **例如**：`search_provider.dart` 应移动到 `features/search/search_provider.dart`

#### 场景：全局 Provider 保留

- **当**某个 Provider 被多个功能模块使用
- **则**该 Provider 应保留在 `presentation/providers` 中
- **例如**：`playback_provider.dart`、`navigation_provider.dart`

### 需求：清理 core/utils

系统应清理 `core/utils` 中的不合适文件，将 UI 相关工具类移动到合适位置。

#### 场景：删除示例代码

- **当**查看 `core/utils/error_handling_example.dart`
- **则**应删除该示例代码文件

#### 场景：移动 UI 组件

- **当**查看 `core/utils/error_dialog.dart` 和 `error_toast.dart`
- **则**这些 UI 组件应移动到 `presentation/widgets/common/` 或 `core/presentation/`

### 需求：widgets 原子设计优化

系统应优化 widgets 的原子设计结构，增加 organisms 层以容纳复杂组件。

#### 场景：复杂组件识别

- **当**某个组件非常复杂（如 mini_player 包含进度条、按钮、下拉菜单）
- **则**该组件应归类为 organism
- **并且**放在 `presentation/widgets/organisms/` 中

## 修改的需求

无

## 移除的需求

无
