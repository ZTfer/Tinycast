# 下拉菜单系统重构与 Episode 下拉菜单增强 Spec

## Why
当前项目中的下拉菜单组件分散在不同位置（如 speed_dropdown、sleep_dropdown、episode_dropdown 等），缺乏统一的管理和复用机制。需要建立一个集中的下拉菜单文件夹来统一管理所有下拉菜单功能，并增强 Episode 下拉菜单，实现收藏/取消收藏和拷贝链接的核心功能。

## What Changes
- 在 `lib/presentation/widgets/organisms/` 下创建统一的 `dropdown` 文件夹，集中管理所有下拉菜单组件
- 在 `dropdown` 文件夹内创建 `episode_dropdown` 子文件夹，实现 Episode 下拉菜单功能
- 实现 Episode 收藏/取消收藏功能（基于已有的 isFavorite 字段和 onToggleFavorite 回调）
- 实现拷贝链接功能：点击按钮后复制当前 episode 的 link 字段到剪贴板，并显示 toast 提示
- **重构影响**：将现有的 episode_dropdown 从 `organisms/episode_dropdown/` 迁移到新的 `organisms/dropdown/episode_dropdown/` 位置

## Impact
- Affected specs: episode-isfavorite-field（已完成的收藏状态支持）
- Affected code:
  - `lib/presentation/widgets/organisms/episode_dropdown/` → 迁移到新位置
  - `lib/presentation/widgets/organisms/dropdown/` → 新建目录结构
  - 使用 EpisodeDropdown 的组件需要更新 import 路径

## ADDED Requirements

### Requirement: 统一的下拉菜单目录结构

系统 SHALL 在 `lib/presentation/widgets/organisms/dropdown/` 目录下提供统一的下拉菜单管理结构：

```
lib/presentation/widgets/organisms/dropdown/
├── episode_dropdown/
│   ├── episode_dropdown.dart          # Episode 下拉菜单主组件
│   └── episode_dropdown_item.dart     # 菜单项组件
├── (未来其他下拉菜单)
```

#### Scenario: 目录结构创建成功
- **WHEN** 开发者查看 `lib/presentation/widgets/organisms/dropdown/` 目录
- **THEN** 该目录存在且包含 `episode_dropdown` 子目录
- **AND** `episode_dropdown` 目录包含完整的组件文件

### Requirement: Episode 下拉菜单的收藏功能

EpisodeDropdown 组件 SHALL 支持收藏/取消收藏操作：

- 接收 `bool isFavorite` 参数表示当前收藏状态
- 接收 `VoidCallback? onToggleFavorite` 回调函数
- 根据收藏状态动态显示：
  - 未收藏时：显示 "收藏" 文本和 LucideIcons.star 图标
  - 已收藏时：显示 "取消收藏" 文本和 LucideIcons.starOff 图标
- 点击收藏项时调用 onToggleFavorite 回调

#### Scenario: 显示未收藏状态的收藏按钮
- **WHEN** isFavorite = false
- **THEN** 显示 "收藏" 文本和星形图标（LucideIcons.star）

#### Scenario: 显示已收藏状态的取消收藏按钮
- **WHEN** isFavorite = true
- **THEN** 显示 "取消收藏" 文本和空心星形图标（LucideIcons.starOff）

#### Scenario: 点击收藏按钮触发回调
- **WHEN** 用户点击收藏/取消收藏按钮
- **THEN** 调用 onToggleFavorite 回调函数（如果非 null）

### Requirement: Episode 下拉菜单的拷贝链接功能

EpisodeDropdown 组件 SHALL 支持拷贝 Episode 链接功能：

- 显示 "拷贝链接" 菜单项（图标：LucideIcons.copy）
- 接收 `String? link` 参数表示当前 episode 的链接地址
- 点击时：
  1. 检查 link 是否为空
  2. 如果 link 非空，使用 Clipboard.setData 将 link 复制到剪贴板
  3. 复制成功后显示 toast 提示 "链接已复制"
  4. 如果 link 为空，不执行复制操作或显示提示

#### Scenario: 成功拷贝非空链接
- **WHEN** 用户点击 "拷贝链接" 按钮 且 link = "https://example.com/episode"
- **THEN** 将 "https://example.com/episode" 复制到系统剪贴板
- **AND** 显示 toast 提示 "链接已复制"

#### Scenario: 处理空链接情况
- **WHEN** 用户点击 "拷贝链接" 按钮 且 link = null
- **THEN** 不执行复制操作
- **OR** 显示提示信息告知用户无可用链接

### Requirement: Toast 提示展示

系统 SHALL 在拷贝链接成功后展示视觉反馈：

- 使用项目现有的 VerticalIconToast 组件或类似机制
- Toast 内容：图标（勾选图标）+ 文本 "链接已复制"
- Toast 显示时长：约 2 秒后自动消失
- Toast 位置：屏幕中央或底部居中

#### Scenario: 复制成功后显示 Toast
- **WHEN** 链接成功复制到剪贴板
- **THEN** 显示包含成功图标的 toast 提示
- **AND** toast 文本为 "链接已复制"
- **AND** toast 在 2 秒后自动消失

## MODIFIED Requirements

### Requirement: EpisodeDropdown 组件接口

修改后的 EpisodeDropdown 组件 SHALL 提供以下接口：

```dart
class EpisodeDropdown extends StatelessWidget {
  final VoidCallback? onItemSelected;           // 通用选中回调
  final bool isFavorite;                         // 收藏状态
  final VoidCallback? onToggleFavorite;         // 收藏切换回调
  final String? link;                            // Episode 链接（用于拷贝）
  final VoidCallback? onCopyLink;               // 拷贝链接回调（可选，内部实现默认逻辑）

  const EpisodeDropdown({
    this.onItemSelected,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.link,
    this.onCopyLink,
  });
}
```

**Reason**: 增加对拷贝链接功能的支持，同时保持向后兼容性。

## REMOVED Requirements

无移除的需求。现有功能将被保留并迁移到新位置。
