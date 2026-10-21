# 主题系统概述

TinyCast 不使用 Material 的 `ThemeData`，而是用一套由 HOCON 文件驱动的自定义主题：
颜色、文字排版和部分 Widget 布局参数写在 `assets/themes/*.conf`，应用启动时由
`ThemeLoader` 解析并缓存，UI 通过 `AppTheme.fromBrightness(...)` 取得
`AppThemeData` 后读取具体样式。

---

## 1. 设计原则

- **HOCON 驱动**：颜色、排版和 Widget 样式集中在 `assets/themes/` 下的 `.conf`
  文件中，支持注释、`include` 和 `${...}` 引用。
- **亮色 / 暗色双调色板**：每个颜色同时定义 `light` 和 `dark` 两个值。
- **启动时预加载**：`main()` 在 `runApp` 前调用 `ThemeLoader.preloadThemeConfigs()`，
  把解析结果放进静态缓存，运行时读取不涉及文件 I/O。
- **统一访问入口**：颜色、文字样式、间距、圆角和阴影都通过 `AppThemeData` 获取。
- **编译时常量兜底**：HOCON 加载失败或显式切到硬编码模式时，回退到
  `AppColors` / `AppTextStyles` 中的 `const` 常量。

### 为什么不用 Material ThemeData？

Material 的 `ThemeData` 绑定了大量项目不需要的组件样式（FAB、SnackBar、Chip 等），
且颜色语义与本项目的设计系统不一致。自定义主题只暴露项目实际使用的 token，
避免在 Material 体系里做二次覆盖。应用根组件是 `WidgetsApp`（见 `lib/main.dart`），
不是 `MaterialApp`。

---

## 2. 文件结构

```text
assets/themes/
├── colors.conf        # 调色板（light / dark）
├── typography.conf    # 文字排版（含 desktop / tablet / mobile 变体）
└── styles.conf        # 通过 include 合并前两者，定义 Widget / 页面布局样式

lib/core/theme/
├── app_colors.dart        # 颜色编译时常量（HOCON 不可用时的兜底）
├── app_text_styles.dart   # 文字样式常量 + 全局字体 fallback 列表
├── app_theme_config.dart  # 一套亮或暗调色板的运行时快照
├── app_theme.dart         # 静态入口：AppTheme.light / dark / fromBrightness
├── theme_data.dart        # AppThemeData、间距、圆角、阴影与 Widget 样式 getter
├── theme_loader.dart      # HOCON 解析器 + 启动预加载 + 静态缓存
└── theme_source_flag.dart # ThemeSource.useHardcoded 源切换开关
```

项目**没有** `lib/core/providers/theme_provider.dart`，也没有 `ThemeNotifier`。
主题不经过 Riverpod 管理，不持久化用户选择，也不支持应用内手动切换亮暗模式。

---

## 3. 启动流程与数据流

1. `main()` 调用 `_preloadTheme()`（`lib/main.dart`）。
2. 若 `ThemeSource.useHardcoded == true`，打印
   `ℹ️ 使用硬编码主题常量（lib/core/theme）` 并直接返回。
3. 否则调用 `ThemeLoader.preloadThemeConfigs()`，解析并缓存：
   - `cachedThemeConfigs`：`light` / `dark` 两套 `AppThemeConfig`，来自
     `colors.conf`；
   - `cachedWidgetStyles['textStyles']`：`typography.conf` 展平后的
     `TextStyle`，键形如 `h1_light`、`h3_desktop_dark`；
   - `cachedWidgetStyles['styles']` / `['stylesDark']`：`styles.conf` 分别按
     light / dark 调色板解析后的结构；
   - `cachedWidgetStyles['widgetTextStyles']`：从 `styles.conf` 的 `widgets` /
     `page` 节点提取的 `TextStyle`，键形如
     `widgets_episode_item_title_light`。
4. 加载成功后打印 `✅ HOCON 主题配置加载完成（使用 .conf 文件）`。
5. Widget 在 `build` 中调用
   `AppTheme.fromBrightness(MediaQuery.platformBrightnessOf(context))` 得到
   `AppThemeData`，再读取颜色 / 文字样式。

加载失败时的日志与行为：

- `colors.conf` 失败：`[ThemeLoader] Colors preload failed, using compiled defaults`，
  `cachedThemeConfigs` 回退到 `AppColors` 常量；
- `typography.conf` 失败：`[ThemeLoader] Typography load failed, using defaults`，
  文字样式 getter 回退到 `AppTextStyles`；
- `styles.conf` 失败：`[ThemeLoader] Styles preload failed`，Widget 布局样式
  使用 `AppThemeData` 中的硬编码默认值。

`ThemeLoader` 只在启动时预加载，运行时不监听文件变化。修改 `.conf` 后需要
重启应用（重新构建资源）才能生效，不存在“保存文件即热更新”。

---

## 4. 两种颜色来源

颜色有两套来源，由 `ThemeSource.useHardcoded` 决定：

| 取值 | 颜色来源 | 文字 / Widget 样式来源 |
|---|---|---|
| `false`（默认） | `colors.conf` | `typography.conf` + `styles.conf` |
| `true` | `AppColors` 常量 | `AppTextStyles` 常量 |

默认值是 `false`，即 HOCON 优先。需要注意：`AppColors` 只是兜底常量，
**并不与 `colors.conf` 完全一致**（例如 `label.primary.light` 在 HOCON 中是
`#E6000000`，在 `AppColors.labelPrimaryLight` 中是 `0xFF000000`）。
把开关改成 `true` 会改变实际视觉效果，不能把它当作“等价的无文件模式”。
差异清单见 [colors.md](./colors.md)。

---

## 5. 亮暗模式

主题跟随系统亮度，没有应用内开关，也没有持久化设置：

- `_MyAppState` 监听 `didChangePlatformBrightness`，亮度变化时重建
  `WidgetsApp` 的默认文字样式；
- 每个使用主题的 Widget 在 `build` 中读取
  `MediaQuery.platformBrightnessOf(context)` 并调用 `AppTheme.fromBrightness`；
- `AppTheme.light` / `AppTheme.dark` 也可直接使用，适合与亮度无关的固定场景
  （如桌面多窗口初始化时的窗口尺寸）。

---

## 6. HOCON 语法与限制

`ThemeLoader` 内置的是轻量解析器，不是完整的 HOCON 实现。已支持：

- `#` 和 `//` 单行注释；
- 嵌套对象：`key { sub { value = "x" } }`；
- 行首 `include "colors.conf"`，路径相对当前文件；
- 整值引用 `${palettes.label.primary.light}`；
- 引用中的调色板切换：加载 dark 版 `styles.conf` 时，引用末尾的 `.light`
  会被自动替换为 `.dark`。

不支持：

- 点号键赋值（`a.b = 1`），必须写成嵌套对象；
- 引用嵌在字符串中间（如 `"prefix-${x}"`），只有整个值是一个 `${...}` 时才会解析；
- 多行字符串和数组；
- 一行内写多个键值对。

---

## 7. 快速上手

```dart
import 'package:tinycast/core/theme/app_theme.dart';

final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Container(color: theme.backgroundPrimary);
Text('标题', style: theme.h1);
SizedBox(height: theme.spacingMd);
```

`AppThemeData` 提供：

- 颜色：`backgroundPrimary` / `backgroundSecondary` / `backgroundTertiary`、
  `labelPrimary` / `labelSecondary` / `labelTertiary` / `labelQuaternary`、
  `brandPrimary` / `brandSecondary` / `brandBlue`、`overlayDefault`、`gray30`；
- 文字：`h1` / `h2` / `h3` / `bodyLarge` / `bodyMedium` / `bodySmall` /
  `caption` / `button`，以及 `episodeItemTitle` 等 Widget 专用样式；
- 间距：`spacingXxs` 到 `spacingXxl`；
- 圆角：`borderRadiusXs` 到 `borderRadiusFull`；
- 阴影：`shadowSm` / `shadowMd` / `shadowLg`；
- 布局：`homeToolbarPadding`、`bodyPadding`、`dividerColor`、窗口尺寸等。

---

## 8. 相关文档

- [颜色系统使用指南](./colors.md)
- [字体排版使用指南](./typography.md)
- 项目编码约定：[`.agents/rules/ai-rules-for-flutter-and-dart.md`](../../.agents/rules/ai-rules-for-flutter-and-dart.md)
