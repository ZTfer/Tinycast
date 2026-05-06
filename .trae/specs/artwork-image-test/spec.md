# ArtworkImage Widget 测试 Spec

## Why
ArtworkImage 组件是封面图展示的核心原子组件，涉及本地文件检查、网络图片加载、后台下载缓存等复杂逻辑，目前缺少测试覆盖。需要按照需求文档 `test/docs/lib/Presentation/widgets/atoms/artwork_image.md` 中的规格添加 Widget 测试，确保图片展示逻辑的正确性。

## What Changes
- 新增 `test/presentation/widgets/atoms/artwork_image_test.dart` 测试文件
- 对 ArtworkImage 的三种构造方式、图片展示逻辑、占位图逻辑、borderRadius 裁剪、didUpdateWidget 重置逻辑进行 Widget 测试

## Impact
- Affected code: `lib/presentation/widgets/atoms/artwork_image/artwork_image.dart`
- 测试文件: `test/presentation/widgets/atoms/artwork_image_test.dart`

## ADDED Requirements

### Requirement: ArtworkImage 构造函数测试
系统 SHALL 通过以下构造方式正确创建 ArtworkImage 实例：
- 默认构造函数 `ArtworkImage()`
- 工厂构造函数 `ArtworkImage.fromEpisode()`
- 工厂构造函数 `ArtworkImage.fromPodcast()`

#### Scenario: 默认构造函数创建
- **WHEN** 使用 `ArtworkImage(artworkUrl: 'https://example.com/img.jpg')` 创建
- **THEN** 组件成功渲染，artworkPath 和 artworkUrl 正确传递

#### Scenario: fromEpisode 构造
- **WHEN** 使用 `ArtworkImage.fromEpisode(episode)` 创建
- **THEN** artworkPath 和 artworkUrl 从 episode 实体自动提取

#### Scenario: fromPodcast 构造
- **WHEN** 使用 `ArtworkImage.fromPodcast(podcast)` 创建
- **THEN** artworkPath 和 artworkUrl 从 podcast 实体自动提取

### Requirement: 本地文件存在时直接展示
系统 SHALL 在本地文件存在时直接使用 `Image.file` 展示封面图。

#### Scenario: artworkPath 指向的本地文件存在
- **WHEN** artworkPath 不为空且对应文件存在
- **THEN** 渲染 `Image.file` 组件展示本地图片

### Requirement: 本地文件不存在时展示占位图
系统 SHALL 在本地文件不存在时展示 SVG 占位图，并触发后台下载。

#### Scenario: artworkPath 为空
- **WHEN** artworkPath 为 null 或空字符串
- **THEN** 展示默认 SVG 占位图（image_placeholder.svg）

#### Scenario: artworkPath 指向的文件不存在
- **WHEN** artworkPath 不为空但对应文件不存在
- **THEN** 展示默认 SVG 占位图

### Requirement: 有 artworkUrl 时使用 CachedNetworkImage
系统 SHALL 在有网络 URL 时使用 CachedNetworkImage 加载网络图片。

#### Scenario: artworkUrl 不为空
- **WHEN** artworkUrl 有值且本地文件不存在
- **THEN** 使用 `CachedNetworkImage` 加载网络图片

#### Scenario: artworkUrl 为空
- **WHEN** artworkUrl 为 null 或空字符串
- **THEN** 展示默认 SVG 占位图（errorWidget）

### Requirement: 自定义 placeholder 和 errorWidget
系统 SHALL 支持调用方自定义 placeholder 和 errorWidget。

#### Scenario: 传入自定义 placeholder
- **WHEN** 传入 `placeholder: Text('loading')`
- **THEN** 网络图片加载中时展示自定义 placeholder

#### Scenario: 传入自定义 errorWidget
- **WHEN** 传入 `errorWidget: Text('error')`
- **THEN** 图片加载失败时展示自定义 errorWidget

#### Scenario: 不传入 placeholder 和 errorWidget
- **WHEN** 不传入 placeholder 和 errorWidget
- **THEN** 默认使用 SVG 占位图

### Requirement: borderRadius 裁剪
系统 SHALL 根据 borderRadius 参数对封面图进行圆角裁剪。

#### Scenario: borderRadius > 0
- **WHEN** borderRadius = 6
- **THEN** 使用 `ClipRRect` 包裹，圆角为 6

#### Scenario: borderRadius = 0
- **WHEN** borderRadius = 0（默认值）
- **THEN** 不使用 `ClipRRect` 包裹

### Requirement: buildPlaceholder 静态方法
系统 SHALL 提供 `ArtworkImage.buildPlaceholder()` 静态方法供外部使用。

#### Scenario: 调用 buildPlaceholder
- **WHEN** 调用 `ArtworkImage.buildPlaceholder(width: 34, height: 34, borderRadius: 6)`
- **THEN** 返回带圆角裁剪的 SVG 占位图 Widget

#### Scenario: buildPlaceholder 无圆角
- **WHEN** 调用 `ArtworkImage.buildPlaceholder(width: 34, height: 34)`
- **THEN** 返回不带 ClipRRect 的 SVG 占位图 Widget

### Requirement: didUpdateWidget 响应属性变化
系统 SHALL 在 artworkPath 或 artworkUrl 变化时重置状态并重新检查。

#### Scenario: artworkPath 变化
- **WHEN** widget 更新后 artworkPath 改变
- **THEN** 重置 _localFile 和 _downloadTriggered，重新触发检查

### Requirement: 防重复下载
系统 SHALL 确保同一组件实例只触发一次后台下载。

#### Scenario: 下载已触发
- **WHEN** _downloadTriggered 为 true
- **THEN** 不再重复触发下载
