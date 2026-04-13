# Tasks

- [x] Task 1: 创建统一的 dropdown 目录结构
  - [x] 在 `lib/presentation/widgets/organisms/` 下创建 `dropdown` 文件夹
  - [x] 在 `dropdown` 文件夹内创建 `episode_dropdown` 子文件夹

- [x] Task 2: 迁移现有 EpisodeDropdown 组件到新位置
  - [x] 将 `lib/presentation/widgets/organisms/episode_dropdown/episode_dropdown.dart` 移动到 `lib/presentation/widgets/organisms/dropdown/episode_dropdown/episode_dropdown.dart`
  - [x] 将 `lib/presentation/widgets/organisms/episode_dropdown/episode_dropdown_item.dart` 移动到 `lib/presentation/widgets/organisms/dropdown/episode_dropdown/episode_dropdown_item.dart`
  - [x] 更新 episode_dropdown.dart 中的 import 路径以适配新位置

- [x] Task 3: 更新 EpisodeDropdown 组件接口
  - [x] 添加 `String? link` 参数用于存储 episode 链接
  - [x] 添加 `VoidCallback? onCopyLink` 可选回调参数
  - [x] 保持现有参数（onItemSelected, isFavorite, onToggleFavorite）不变

- [x] Task 4: 实现拷贝链接功能
  - [x] 在 episode_dropdown.dart 中导入 `package:flutter/services.dart`（用于 Clipboard）
  - [x] 在拷贝链接菜单项的 onPressed 回调中实现复制逻辑：
    - 检查 link 是否为空
    - 如果 link 非空，调用 `Clipboard.setData(ClipboardData(text: link!))`
    - 如果提供了 onCopyLink 回调，调用该回调
  - [x] 处理 link 为空的情况（不执行复制或显示提示）

- [x] Task 5: 实现 Toast 提示功能
  - [x] 在 episode_dropdown.dart 中导入 toast 相关组件
  - [x] 创建显示 toast 的方法，使用 VerticalIconToast 或类似组件
  - [x] 在拷贝链接成功后调用 toast 显示方法
  - [x] 配置 toast 显示内容：勾选图标 + "链接已复制" 文本
  - [x] 配置 toast 显示时长：2 秒后自动消失

- [x] Task 6: 更新所有引用 EpisodeDropdown 的组件
  - [x] 搜索项目中所有 import episode_dropdown 的文件
  - [x] 更新 import 路径从 `package:tinycast/presentation/widgets/organisms/episode_dropdown/episode_dropdown.dart` 到 `package:tinycast/presentation/widgets/organisms/dropdown/episode_dropdown/episode_dropdown.dart`
  - [x] 验证所有引用组件能正常编译

- [x] Task 7: 验证收藏功能正常工作
  - [x] 确认 isFavorite 参数正确传递
  - [x] 确认 onToggleFavorite 回调正确设置
  - [x] 验证收藏/取消收藏按钮的文本和图标根据状态正确显示
  - [x] 验证点击收藏按钮能正确触发回调

- [x] Task 8: 测试拷贝链接功能
  - [x] 测试拷贝非空链接的场景（验证剪贴板内容）
  - [x] 测试拷贝空链接的场景（验证不报错）
  - [x] 验证 toast 提示正确显示
  - [x] 验证 toast 在 2 秒后自动消失

- [x] Task 9: 清理旧文件
  - [x] 删除 `lib/presentation/widgets/organisms/episode_dropdown/` 旧目录（如果迁移成功且无其他引用）

# Task Dependencies

- [Task 2] 依赖于 [Task 1]（需要先创建目录结构）
- [Task 3] 依赖于 [Task 2]（需要先迁移组件）
- [Task 4] 依赖于 [Task 3]（需要先更新组件接口）
- [Task 5] 依赖于 [Task 4]（需要先实现拷贝逻辑）
- [Task 6] 依赖于 [Task 2]（需要先完成迁移）
- [Task 7] 可与 [Task 4, Task 5] 并行
- [Task 8] 依赖于 [Task 4, Task 5]（需要先实现功能）
- [Task 9] 依赖于 [Task 6]（需要先更新所有引用）
