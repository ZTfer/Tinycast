# Checklist

- [x] GetFavoriteEpisodesUseCase 已创建并能正确过滤和排序收藏 episodes
- [x] favoriteEpisodesProvider 正确暴露收藏 episodes 列表和 loading 状态
- [x] FavoriteEmptyPage 展示正确的空状态 UI（占位图+提示文字）
- [x] Favorite 页面改为 ConsumerWidget 并集成 Riverpod providers
- [x] Favorite 页面正确处理三种状态：加载中、空列表、有数据
- [x] 使用通用 EpisodeItem 组件展示收藏列表（非自定义组件）
- [x] EpisodeItem 配置了正确的回调函数（播放、打开详情）
- [x] 列表最后一项不显示分隔线
- [x] 移除了所有旧的自定义组件导入（favorite_control_bar, favorite_episode_dropdown, favorite_episode_info, favorite_list_item）
- [x] 代码风格与 queue/up_next_queue.dart 保持一致
