# Artwork Image

## 用途

用于展示对应episode的podcast或者episode封面图，或者不展示封面图

### 文件路径

原始代码逻辑路径：lib/presentation/widgets/atoms/artwork_image
测试代码路径：test/presentation/widgets/atoms/artwork_image_test.dart

## 构造函数

组件提供三种构造方式：

### 1. 默认构造函数 `ArtworkImage()`

直接传入 `artworkPath` 和 `artworkUrl` 参数。

### 2. `ArtworkImage.fromEpisode(Episode episode)`

从 Episode 实体自动提取 `artworkPath` 和 `artworkUrl`，适用于展示单集封面。

### 3. `ArtworkImage.fromPodcast(Podcast podcast)`

从 Podcast 实体自动提取 `artworkPath` 和 `artworkUrl`，适用于展示播客封面。

## 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `artworkPath` | `String?` | `null` | 本地文件路径，优先级最高 |
| `artworkUrl` | `String?` | `null` | 网络图片URL |
| `episode` | `Episode?` | `null` | 单集实体，用于后台下载 |
| `podcast` | `Podcast?` | `null` | 播客实体，用于后台下载 |
| `width` | `double?` | `null` | 图片宽度 |
| `height` | `double?` | `null` | 图片高度 |
| `fit` | `BoxFit` | `BoxFit.cover` | 图片填充模式 |
| `borderRadius` | `double` | `0` | 圆角半径，大于0时自动添加 ClipRRect |
| `placeholder` | `Widget?` | `null` | 自定义占位组件，未指定时使用默认SVG占位图 |
| `errorWidget` | `Widget?` | `null` | 自定义错误组件，未指定时使用默认SVG占位图 |

## 图片加载优先级流程图

```
┌─────────────────────────────────────┐
│         ArtworkImage 初始化          │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  检查 artworkPath 是否有本地文件？   │
└──────┬──────────────────┬───────────┘
       │ YES              │ NO
       ▼                  ▼
┌──────────────┐  ┌──────────────────────────────┐
│  展示本地文件 │  │  展示 CachedNetworkImage      │
│  (Image.file)│  │  (网络图片加载)                │
└──────┬───────┘  └──────┬───────────────────────┘
       │                 │
       │                 ▼
       │          ┌──────────────────────────────┐
       │          │  网络图片加载中显示 placeholder │
       │          └──────┬───────────────────────┘
       │                 │
       │                 ▼
       │          ┌──────────────────────────────┐
       │          │  加载成功：展示网络图片        │
       │          │  加载失败：展示 errorWidget    │
       │          └──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  后台异步下载封面图（见状态管理）      │
└─────────────────────────────────────┘
```

## 状态管理机制

### didUpdateWidget 刷新机制

当组件的 `artworkPath` 或 `artworkUrl` 发生变化时：
1. 重置 `_localFile` 为 null
2. 重置 `_downloadTriggered` 为 false
3. 重新触发 `_checkAndTriggerDownload()` 检查并下载

这确保了当传入新的 episode/podcast 时，组件能够正确更新显示。

### 防重复下载机制

使用 `_downloadTriggered` 布尔标志位防止重复触发下载：
- 首次检查时设置为 true
- 在 `didUpdateWidget` 中当 artworkPath/artworkUrl 变化时重置为 false
- `_triggerBackgroundDownload()` 方法开头检查该标志，已触发则直接返回

```dart
void _triggerBackgroundDownload() {
  if (_downloadTriggered) return;  // 防重复
  _downloadTriggered = true;
  // ... 执行下载逻辑
}
```

### 并发保护

使用 `_isCheckingLocal` 标志位防止并发检查本地文件：
```dart
Future<void> _checkAndTriggerDownload() async {
  if (_isCheckingLocal) return;
  _isCheckingLocal = true;
  // ... 检查逻辑
}
```

## 降级策略（本地 → 网络 → 占位图）

### 三级降级流程

1. **第一级：本地文件** (`Image.file`)
   - 检查 `artworkPath` 对应的本地文件是否存在
   - 存在则直接展示
   - 加载失败时降级到第二级（网络图片）

2. **第二级：网络图片** (`CachedNetworkImage`)
   - 当本地文件不存在或加载失败时使用
   - 使用 `artworkUrl` 加载网络图片
   - 加载中显示 placeholder
   - 加载失败时降级到第三级

3. **第三级：占位图** (`SvgPicture.asset`)
   - 当 `artworkUrl` 为空或网络加载失败时显示
   - 默认使用 `assets/images/image_placeholder.svg`
   - 可通过 `placeholder` 和 `errorWidget` 参数自定义

### 降级触发条件

```
本地文件存在 → 展示本地
    ↓ (失败)
网络URL有效 → 展示网络图片
    ↓ (失败/URL为空)
展示占位图
```

## 静态方法的用途

### `ArtworkImage.buildPlaceholder()`

静态方法，用于在组件外部单独构建占位图片。

**参数：**
- `width` / `height` - 占位图尺寸
- `fit` - 填充模式（默认 `BoxFit.cover`）
- `borderRadius` - 圆角半径

**返回值：**
- `borderRadius > 0` 时返回 `ClipRRect` 包裹的 `SvgPicture`
- `borderRadius = 0` 时直接返回 `SvgPicture`

**使用场景：**
- 在列表骨架屏中预渲染占位图
- 在加载状态中显示统一样式的占位组件
- 避免创建完整 ArtworkImage 实例的开销

## 图片展示逻辑

### 是否展示图片

不展示图片：不调用任何本地文件，不进行任何网络加载

### 展示图片

#### 如果封面图存在

如果对应的封面图在数据库中存在记录时，先验证对应位置是否有图片文件存在
1. 如果存在：展示对应的图片文件
2. 如果不存在：
  1. 删除数据库对应位置的记录
  2. 异步下载封面图片
  3. 下载成功后更新数据库记录并展示图片
  4. 下载失败时展示默认占位图片

#### 如果封面图不存在

当对应的封面图文件不存在时，也就是数据库没有对应的文件位置记录，则：
1. 异步下载封面图片
2. 下载成功后更新数据库记录并展示图片
3. 下载失败时展示默认占位图片

## 异常处理

在列表中展示artwork_image这个组件时才会触发封面图的异步下载和展示逻辑，如果分面图已经在下载过程中了，则不会重复下载，不要重复触发多个下载逻辑。
