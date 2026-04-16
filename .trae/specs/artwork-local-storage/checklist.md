# Checklist

## 数据模型验证
- [x] Episode 模型包含 artworkPath 字段（String? 类型）
- [x] Podcast 模型包含 artworkPath 字段（String? 类型）
- [x] Isar 模型代码已重新生成（.g.dart 文件更新）

## 文件存储服务验证
- [x] FileStorageService 包含 generateArtworkFileName() 方法
- [x] generateArtworkFileName() 使用 UUID v4 生成文件名
- [x] 文件名格式为 {uuid}.jpg

## 封面图下载服务验证
- [x] downloadAndSaveEpisodeArtwork(Episode) 方法实现完整
- [x] downloadAndSavePodcastArtwork(Podcast) 方法实现完整
- [x] 下载前检查 artworkPath 和文件是否存在（避免重复下载）
- [x] 下载成功后正确保存到 images 目录
- [x] 保存成功后更新数据库中的 artworkPath 字段
- [x] 错误处理完善，包含详细日志记录

## 音频下载集成验证
- [x] AudioDownloadService 在音频下载完成后触发封面图下载
- [x] 封面图下载失败不影响音频下载状态

## UI 层验证
- [x] ArtworkImage Widget 组件创建完成
- [x] 优先从本地 artworkPath 加载图片文件
- [x] 本地文件不存在时回退到网络 URL 加载
- [x] 网络加载成功且 artworkPath 为空时触发后台下载
- [x] 所有 episode/podcast 封面图显示位置已更新为使用新组件
- [x] 离线状态下能正确显示已缓存的封面图

## 端到端流程验证
- [x] 首次加载：从网络下载 → 保存到本地 → 更新数据库 → 显示本地文件
- [x] 二次加载：读取数据库路径 → 加载本地文件 → 跳过网络请求
- [x] 文件丢失：读取数据库路径 → 文件不存在 → 回退网络 → 重新下载保存
- [x] 离线场景：读取数据库路径 → 加载本地文件 → 正常显示（如果文件存在）
