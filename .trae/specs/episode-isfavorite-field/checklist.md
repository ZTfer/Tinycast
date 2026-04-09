# Checklist

- [ ] Favorite Isar 模型（favorite_model.dart）已创建，包含 id、episodeId（@Index）、createdAt 字段
- [ ] Favorite Isar 生成代码（favorite_model.g.dart）已生成
- [ ] IsarService 已注册 FavoriteSchema
- [ ] EpisodeDropdown 组件包含 isFavorite 参数（默认 false）
- [ ] EpisodeDropdown 组件包含 onToggleFavorite 回调参数
- [ ] isFavorite=false 时显示"收藏"+ LucideIcons.star 图标
- [ ] isFavorite=true 时显示"取消收藏"+ LucideIcons.starOff 图标
- [ ] 点击收藏/取消收藏菜单项正确调用 onToggleFavorite 回调
