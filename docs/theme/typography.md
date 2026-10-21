# 字体排版使用指南

TinyCast 的文字样式定义在 `assets/themes/typography.conf`，由 `ThemeLoader`
在启动时展平为 `TextStyle` 并缓存，UI 通过 `AppThemeData` 读取。
`lib/core/theme/app_text_styles.dart` 中的 `AppTextStyles` 是硬编码兜底，
同时提供全局字体 fallback 列表。

---

## 1. 排版配置

### 1.1 基本结构

文字样式统一放在 `textstyles` 节点下：

```hocon
{
  version = 0.1
  name = "Typography"

  textstyles {
    h1 {
      fontsize = "34"
      fontweight = "700"
      lineheight = "1.2"
      letterspacing = "0.37"
      color = "labelPrimary"
    }
  }
}
```

### 1.2 配置项

- `fontsize`：字号，单位 pt；
- `fontweight`：**数值**，对应 `FontWeight.w100` 到 `w900`，例如 `"400"`、`"600"`、
  `"700"`。写成 `"bold"` / `"semibold"` 无法解析，会回退到 `w400`；
- `lineheight`：行高**倍数**，例如 `"1.2"`、`"1.4"`，直接传给 `TextStyle.height`。
  不要写成 `"16/12"` 这类“行高/字号”格式，解析失败会使用默认值 `1.4`；
- `letterspacing`：字间距，单位逻辑像素（pt），可为负值；
- `color`：颜色 key，只能是固定集合中的名字：
  `labelPrimary`、`labelSecondary`、`labelTertiary`、`labelQuaternary`、
  `brandPrimary`、`brandSecondary`、`backgroundPrimary`、`backgroundSecondary`。
  写成未知 key 会静默回退到 `labelPrimary`，不会报错。

### 1.3 响应式变体

带 `desktop` / `tablet` / `mobile` 子节点的样式会按设备类型选择字号等参数；
`color` 写在顶层，三个变体共用：

```hocon
h3 {
  desktop {
    fontsize = "14"
    fontweight = "500"
    lineheight = "1.3"
    letterspacing = "0.35"
  }
  tablet {
    fontsize = "22"
    fontweight = "600"
    lineheight = "1.3"
    letterspacing = "0.35"
  }
  mobile {
    fontsize = "22"
    fontweight = "600"
    lineheight = "1.3"
    letterspacing = "0.35"
  }
  color = "labelPrimary"
}
```

变体选择规则（`AppThemeData._textVariant`）：

1. `macOS` / `Windows` / `Linux` 一律使用 `desktop`；
2. 其余平台取第一个窗口的短边逻辑像素，`>= 600` 使用 `tablet`；
3. 否则使用 `mobile`。

也就是说，iPad 或横屏大屏手机按短边判断，不按当前窗口宽度判断。
若只定义了 `desktop`，其他平台会回退到 `desktop` 值。

### 1.4 当前样式速查

| HOCON key | 变体 | 字号 | 字重 | 行高 | 字间距 | 颜色 key | 用途 |
|---|---|---|---|---|---|---|---|
| `h1` | 无 | 34 | w700 | 1.2 | 0.37 | `labelPrimary` | 大标题 |
| `h2` | 无 | 28 | w700 | 1.2 | 0.35 | `labelPrimary` | 中标题 |
| `h3` | desktop | 14 | w500 | 1.3 | 0.35 | `labelPrimary` | 小标题 / Episode 标题 |
| | tablet / mobile | 22 | w600 | 1.3 | 0.35 | | |
| `bodylarge` | 无 | 17 | w400 | 1.5 | -0.41 | `labelPrimary` | 大正文 |
| `bodymedium` | 无 | 15 | w400 | 1.4 | -0.24 | `labelPrimary` | 标准正文 |
| `bodysmall` | 无 | 13 | w400 | 1.4 | -0.08 | `labelSecondary` | 小正文 |
| `caption1` | desktop / tablet / mobile | 12 | w400 | 1.3 | 0 | `labelTertiary` | 注释、说明 |
| `caption2` | desktop | 10 | w400 | 1.3 | 0 | `labelTertiary` | 更小的辅助文字 |
| | tablet / mobile | 12 | w400 | 1.3 | 0 | | |
| `button` | 无 | 17 | w600 | 1.3 | -0.41 | `labelPrimary` | 按钮文字 |

HOCON key 使用小写（`bodylarge` / `bodymedium` / `bodysmall`），
`AppThemeData` 的 getter 使用驼峰（`bodyLarge` / `bodyMedium` / `bodySmall`），
两者通过固定 key 对应，改名时需要同步修改 `theme_data.dart`。

注意：

- `AppThemeData.caption` 实际读取的是 `caption1`；
- `caption2` 没有对应的 `AppThemeData` getter，目前只在 `styles.conf` 中使用
  （Episode 发布时间、进度条时间标签）；
- `h3` 在桌面端是 14pt / w500，在移动端和平板是 22pt / w600，跨平台视觉差异
  是当前配置的预期行为。

---

## 2. Dart 侧的文字入口

### 2.1 全局字体 fallback

项目**没有**统一的主 `fontFamily`。`main.dart` 在 `WidgetsApp.textStyle` 中注入
字体 fallback 列表：

```dart
textStyle: TextStyle(
  fontFamilyFallback: AppTextStyles.fontFamilyFallback,
  color: _platformBrightness == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000),
  fontSize: 14,
  fontWeight: FontWeight.normal,
),
```

`AppTextStyles.fontFamilyFallback` 覆盖 macOS / Windows / Linux / Android / iOS
的中、繁、日、韩文字体，以及泰语、阿拉伯语、印地语等，最后以 `sans-serif`
收尾。`TextStyle` 默认 `inherit: true`，未显式指定 `fontFamily` 的文字样式会
继承这份 fallback；HOCON 目前也不支持配置字体家族。

### 2.2 AppTextStyles（兜底常量）

`AppTextStyles` 提供与 HOCON 对应的 `const` 常量：

- `h1Light` / `h1Dark`、`h2Light` / `h2Dark`、`h3Light` / `h3Dark`；
- `h3DesktopLight` / `h3DesktopDark`；
- `bodyLargeLight` / `bodyLargeDark`、`bodyMediumLight` / `bodyMediumDark`、
  `bodySmallLight` / `bodySmallDark`；
- `captionLight` / `captionDark`、`buttonLight` / `buttonDark`。

这些常量不含 `fontFamily`，依赖上文的全局 fallback。它们只在
`ThemeSource.useHardcoded == true` 或 HOCON 加载失败时生效。

`caption2` 没有对应的 `AppTextStyles` 常量，硬编码模式下使用 `captionLight` /
`captionDark` 作为替代。

---

## 3. 使用方式

### 3.1 通过 AppThemeData（推荐）

```dart
final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('页面标题', style: theme.h1),
    SizedBox(height: theme.spacingXs),
    Text('副标题', style: theme.h2),
    SizedBox(height: theme.spacingSm),
    Text('正文内容', style: theme.bodyLarge),
    SizedBox(height: theme.spacingXs),
    Text('注：这是补充说明', style: theme.caption),
  ],
);
```

`AppThemeData` 还提供 Widget 专用样式：`episodeItemTitle`、
`episodeItemDescription`、`episodeItemPubDate`、`libraryShowTitle`、
`episodeInfoEpisodeTitle`、`episodeInfoPodcastTitle`、
`episodeProgressTimeLabelStyle`。这些样式由 `styles.conf` 与
`typography.conf` 组合而来，优先使用它们而不是在页面里重新拼样式。

### 3.2 直接使用 AppTextStyles

仅用于不跟随主题或兜底场景：

```dart
Text('大标题', style: AppTextStyles.h1Light);
Text('正文', style: AppTextStyles.bodyMediumDark);
```

### 3.3 基于现有样式微调

```dart
final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Text(
  '自定义样式',
  style: theme.bodyLarge.copyWith(
    color: theme.brandPrimary,
    fontWeight: FontWeight.w600,
  ),
);
```

---

## 4. 添加新文字样式

1. 在 `typography.conf` 的 `textstyles` 下添加新 key。普通样式直接写
   `fontsize` / `fontweight` / `lineheight` / `letterspacing` / `color`；
   需要响应式时添加 `desktop` / `tablet` / `mobile` 子节点。
2. 如需在硬编码模式和加载失败时可用，在 `AppTextStyles` 中添加对应的
   `Light` / `Dark` 常量。
3. 在 `AppThemeData` 中添加 getter：

   ```dart
   TextStyle get caption2 => _isHocon
       ? (_widgetTextStyle('caption2') ??
             _hardcodedTextStyle(
               AppTextStyles.captionLight,
               AppTextStyles.captionDark,
             ))
       : (mode == AppThemeMode.light
             ? AppTextStyles.captionLight
             : AppTextStyles.captionDark);
   ```

4. 运行 `flutter test test/core/theme/`，并在亮 / 暗模式和不同平台变体下检查效果。

key 命名约定：HOCON key 全小写，`AppThemeData` getter 使用驼峰；
如果新 key 带响应式变体，`_widgetTextStyle` 会依次尝试
`{key}_{variant}_{light|dark}`、`{key}_desktop_{light|dark}`、
`{key}_{light|dark}`。

---

## 5. 最佳实践

### 5.1 优先使用 AppThemeData

```dart
Text('标题', style: theme.h1);
Text('正文', style: theme.bodyLarge);
```

不要在页面里手写 `TextStyle(fontSize: 34, fontWeight: FontWeight.w700)`，
否则会绕过 HOCON、响应式变体和全局字体 fallback。

### 5.2 不要手动指定 fontFamily

项目通过 `fontFamilyFallback` 处理跨平台字体。除非有明确的品牌字体需求，
不要在 Widget 里写 `fontFamily: '.SF Pro Text'` 之类的值，否则会破坏
中文 / 日文 / 韩文的 fallback 链。

### 5.3 用 copyWith 做局部调整

```dart
Text('强调正文', style: theme.bodyLarge.copyWith(color: theme.brandPrimary));
```

`copyWith` 会保留字号、行高和 fallback 继承关系，比从头构造 `TextStyle` 更安全。

### 5.4 颜色只写 key

`typography.conf` 的 `color` 必须是 `labelPrimary` 等已知 key。
需要十六进制色值时，放到 `colors.conf` 中定义，再通过 key 或
`styles.conf` 的 `${palettes...}` 引用。

---

## 6. 相关文档

- [主题系统概述](./overview.md)
- [颜色系统使用指南](./colors.md)
