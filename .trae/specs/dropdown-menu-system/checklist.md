# Checklist

## 目录结构
- [ ] `lib/presentation/widgets/organisms/dropdown/` 目录已创建
- [ ] `lib/presentation/widgets/organisms/dropdown/episode_dropdown/` 目录已创建
- [ ] 旧目录 `lib/presentation/widgets/organisms/episode_dropdown/` 已删除（迁移完成后）

## 组件文件
- [ ] `dropdown/episode_dropdown/episode_dropdown.dart` 文件存在且包含完整实现
- [ ] `dropdown/episode_dropdown/episode_dropdown_item.dart` 文件存在且完整

## EpisodeDropdown 接口
- [ ] 组件包含 `String? link` 参数
- [ ] 组件包含 `VoidCallback? onCopyLink` 可选参数
- [ ] 组件保留原有参数：onItemSelected, isFavorite, onToggleFavorite
- [ ] 所有参数有合理的默认值

## 收藏功能
- [ ] 未收藏状态（isFavorite=false）显示 "收藏" 文本和 LucideIcons.star 图标
- [ ] 已收藏状态（isFavorite=true）显示 "取消收藏" 文本和 LucideIcons.starOff 图标
- [ ] 点击收藏按钮调用 onToggleFavorite 回调（如果非 null）

## 拷贝链接功能
- [ ] 显示 "拷贝链接" 菜单项，使用 LucideIcons.copy 图标
- [ ] 点击拷贝链接按钮时检查 link 是否为空
- [ ] link 非空时调用 Clipboard.setData 复制到剪贴板
- [ ] link 为空时不执行复制操作或给出提示
- [ ] 如果提供了 onCopyLink 回调，在复制时调用该回调

## Toast 提示
- [ ] 拷贝链接成功后显示 toast 提示
- [ ] toast 包含成功图标（如勾选图标）
- [ ] toast 文本内容为 "链接已复制"
- [ ] toast 在约 2 秒后自动消失
- [ ] toast 样式与项目现有风格一致

## Import 路径更新
- [ ] 所有引用 episode_dropdown.dart 的文件 import 路径已更新为新路径
- [ ] 所有引用 episode_dropdown_item.dart 的文件 import 路径已更新为新路径
- [ ] 项目能够成功编译，无 import 错误

## 功能测试验证
- [ ] 收藏/取消收藏功能正常工作
- [ ] 拷贝非空链接功能正常工作（可手动测试剪贴板内容）
- [ ] 拷贝空链接不导致崩溃
- [ ] Toast 提示正常显示和消失
- [ ] 整体下拉菜单 UI 显示正常，无布局问题
