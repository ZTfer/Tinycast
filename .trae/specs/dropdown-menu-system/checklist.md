# Checklist

## 目录结构
- [x] `lib/presentation/widgets/organisms/dropdown/` 目录已创建
- [x] `lib/presentation/widgets/organisms/dropdown/episode_dropdown/` 目录已创建
- [x] 旧目录 `lib/presentation/widgets/organisms/episode_dropdown/` 已删除（迁移完成后）

## 组件文件
- [x] `dropdown/episode_dropdown/episode_dropdown.dart` 文件存在且包含完整实现
- [x] `dropdown/episode_dropdown/episode_dropdown_item.dart` 文件存在且完整

## EpisodeDropdown 接口
- [x] 组件包含 `String? link` 参数
- [x] 组件包含 `VoidCallback? onCopyLink` 可选参数
- [x] 组件保留原有参数：onItemSelected, isFavorite, onToggleFavorite
- [x] 所有参数有合理的默认值

## 收藏功能
- [x] 未收藏状态（isFavorite=false）显示 "收藏" 文本和 LucideIcons.star 图标
- [x] 已收藏状态（isFavorite=true）显示 "取消收藏" 文本和 LucideIcons.starOff 图标
- [x] 点击收藏按钮调用 onToggleFavorite 回调（如果非 null）

## 拷贝链接功能
- [x] 显示 "拷贝链接" 菜单项，使用 LucideIcons.copy 图标
- [x] 点击拷贝链接按钮时检查 link 是否为空
- [x] link 非空时调用 Clipboard.setData 复制到剪贴板
- [x] link 为空时不执行复制操作或给出提示
- [x] 如果提供了 onCopyLink 回调，在复制时调用该回调

## Toast 提示
- [x] 拷贝链接成功后显示 toast 提示
- [x] toast 包含成功图标（如勾选图标）
- [x] toast 文本内容为 "链接已复制"
- [x] toast 在约 2 秒后自动消失
- [x] toast 样式与项目现有风格一致

## Import 路径更新
- [x] 所有引用 episode_dropdown.dart 的文件 import 路径已更新为新路径
- [x] 所有引用 episode_dropdown_item.dart 的文件 import 路径已更新为新路径
- [x] 项目能够成功编译，无 import 错误

## 功能测试验证
- [x] 收藏/取消收藏功能正常工作
- [x] 拷贝非空链接功能正常工作（可手动测试剪贴板内容）
- [x] 拷贝空链接不导致崩溃
- [x] Toast 提示正常显示和消失
- [x] 整体下拉菜单 UI 显示正常，无布局问题
