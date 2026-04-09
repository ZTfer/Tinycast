# Checklist

- [ ] Episode Isar 模型（episode_model.dart）包含 isFavorite 字段且类型为 bool
- [ ] Isar 生成的代码（episode_model.g.dart）已更新，包含 isFavorite 的序列化/反序列化/查询支持
- [ ] Domain 层 Episode 实体（episode.dart）包含 isFavorite 字段且默认值为 false
- [ ] EpisodeDropdown 组件接收 episode 和 onToggleFavorite 参数
- [ ] EpisodeDropdown 在 isFavorite=false 时显示"收藏"+ LucideIcons.star 图标
- [ ] EpisodeDropdown 在 isFavorite=true 时显示"取消收藏"+ LucideIcons.starOff 图标
- [ ] 点击收藏/取消收藏菜单项时正确调用 onToggleFavorite 回调
- [ ] 所有 Episode 构造函数调用处兼容新增的 isFavorite 字段（无编译错误）
