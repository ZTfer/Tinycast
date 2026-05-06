# Tasks

- [x] Task 1: 创建测试文件和基础测试辅助设施
  - [x] 创建 `test/presentation/widgets/atoms/artwork_image_test.dart`
  - [x] 创建测试用 Episode 和 Podcast 工厂方法
  - [x] 创建测试用 MaterialApp 包裹器

- [x] Task 2: 编写构造函数测试
  - [x] 测试默认构造函数 `ArtworkImage()` 渲染
  - [x] 测试 `ArtworkImage.fromEpisode()` 自动提取 artworkPath/artworkUrl
  - [x] 测试 `ArtworkImage.fromPodcast()` 自动提取 artworkPath/artworkUrl

- [x] Task 3: 编写图片展示逻辑测试
  - [x] 测试 artworkUrl 不为空时渲染 CachedNetworkImage
  - [x] 测试 artworkUrl 为空时渲染默认 SVG 占位图
  - [x] 测试自定义 placeholder 传入时使用自定义 placeholder
  - [x] 测试自定义 errorWidget 传入时使用自定义 errorWidget

- [x] Task 4: 编写 borderRadius 裁剪测试
  - [x] 测试 borderRadius > 0 时存在 ClipRRect 包裹
  - [x] 测试 borderRadius = 0 时无 ClipRRect 包裹

- [x] Task 5: 编写 buildPlaceholder 静态方法测试
  - [x] 测试 buildPlaceholder 带圆角返回 ClipRRect + SvgPicture
  - [x] 测试 buildPlaceholder 无圆角返回 SvgPicture

- [x] Task 6: 编写 didUpdateWidget 和防重复下载测试
  - [x] 测试 artworkPath 变化时状态重置
  - [x] 测试 _downloadTriggered 防重复触发

# Task Dependencies
- Task 2 ~ Task 6 依赖 Task 1（测试基础设施）
- Task 2 ~ Task 6 之间可并行
