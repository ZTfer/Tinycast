# 颜色系统使用指南

TinyCast 的颜色定义在 `assets/themes/colors.conf`，默认由 `ThemeLoader` 在启动时
解析成 `AppThemeConfig`，再通过 `AppThemeData` 暴露给 UI。
`lib/core/theme/app_colors.dart` 中的 `AppColors` 是硬编码兜底，不是主数据源。

---

## 1. 颜色配置

### 1.1 文件结构

`colors.conf` 使用嵌套对象组织调色板：

```hocon
{
  version = 0.1
  name = "Colors"

  palettes {
    brand {
      primary {
        light = "#FF6200EE"
        dark = "#FFBB86FC"
      }
    }
  }
}
```

每个颜色必须有 `light` 和 `dark` 两个值。`ThemeLoader` 按当前亮度分别构建
`AppThemeConfig`，缺失对应变体会导致解析失败。

### 1.2 颜色格式

统一使用 `#AARRGGBB`（ARGB 十六进制）：

- `AA`：Alpha，`00` 全透明，`FF` 不透明；
- `RR` / `GG` / `BB`：红、绿、蓝通道。

Alpha 是十六进制字节，不是百分比。例如：

- `#E6000000`：Alpha `0xE6` ≈ 90% 不透明的黑色；
- `#95FFFFFF`：Alpha `0x95` ≈ 58% 不透明的白色；
- `#803C3C43`：Alpha `0x80` = 50% 不透明；
- `#FF3C3C43`：完全不透明。

### 1.3 调色板一览

| 调色板 | 颜色名 | light | dark | 用途 |
|---|---|---|---|---|
| **brand** | `primary` | `#FF6200EE` | `#FFBB86FC` | 主品牌色、按钮、高亮 |
| | `secondary` | `#FF03DAC6` | `#FF03DAC6` | 辅助品牌色 |
| | `blue` | `#FF0088FF` | `#FF0091FF` | 蓝色强调色 |
| **background** | `primary` | `#FFFFFFFF` | `#FF000000` | 页面主背景 |
| | `secondary` | `#FFF2F2F7` | `#FF1C1C1E` | 卡片、侧栏等次级背景 |
| | `tertiary` | `#FFFFFFFF` | `#FF2C2C2E` | 对话框等第三级背景 |
| | `transparent` | `#00FFFFFF` | `#00FFFFFF` | 完全透明的背景占位 |
| **gray** | `black` | `#FF000000` | `#FF000000` | 纯黑 |
| | `gray-0` | `#00000000` | `#00FFFFFF` | 0% 灰（透明） |
| | `gray-10` | `#10000000` | `#10FFFFFF` | 6% 灰，悬停背景 |
| | `gray-20` | `#20000000` | `#20FFFFFF` | 12% 灰，分隔线 |
| | `gray-30` | `#30000000` | `#30FFFFFF` | 19% 灰，按下背景 |
| | `gray-40` | `#40000000` | `#40FFFFFF` | 25% 灰 |
| | `gray-50` | `#50000000` | `#50FFFFFF` | 31% 灰 |
| **label** | `primary` | `#E6000000` | `#95FFFFFF` | 主要文字 |
| | `secondary` | `#FF3C3C43` | `#70EBEBF5` | 次要文字 |
| | `tertiary` | `#803C3C43` | `#30EBEBF5` | 辅助文字 |
| | `quaternary` | `#183C3C43` | `#16EBEBF5` | 最弱层级文字 |
| **overlay** | `default` | `#20000000` | `#48000000` | 弹窗 / 加载遮罩 |
| | `transparent` | `#00000000` | `#00FFFFFF` | 透明遮罩 |

注意 gray 系列的“百分比”来自 Alpha 字节：`0x10` ≈ 6%，`0x20` ≈ 12%，
`0x30` ≈ 19%，`0x40` ≈ 25%，`0x50` ≈ 31%。

---

## 2. Dart 侧的颜色入口

### 2.1 AppThemeData（推荐）

UI 代码应通过 `AppThemeData` 读取颜色，它会跟随系统亮暗模式：

```dart
final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Container(color: theme.backgroundPrimary);
Text('正文', style: TextStyle(color: theme.labelPrimary));
```

`AppThemeData` 当前暴露的颜色 getter：

- `backgroundPrimary` / `backgroundSecondary` / `backgroundTertiary`
- `labelPrimary` / `labelSecondary` / `labelTertiary` / `labelQuaternary`
- `brandPrimary` / `brandSecondary` / `brandBlue`
- `overlayDefault`
- `gray30`

`background.transparent` 和 `gray-0/10/20/40/50` 没有对应的 `AppThemeData`
getter，目前只在 `styles.conf` 内部通过 `${palettes...}` 引用（例如按钮悬停
背景、分隔线）。如果业务代码需要这些值，按第 4 节扩展。

### 2.2 AppColors（兜底常量）

`lib/core/theme/app_colors.dart` 定义 `const Color` 常量，仅在以下情况生效：

- `ThemeSource.useHardcoded` 被改为 `true`；
- `colors.conf` 预加载失败，`ThemeLoader` 回退到编译时常量。

命名规则为 `{调色板}{颜色名}{Light|Dark}`，例如 `brandPrimaryLight`、
`labelSecondaryDark`。

**当前 `AppColors` 与 `colors.conf` 并不一致**，默认（HOCON）模式下以
`colors.conf` 为准：

- `labelPrimaryLight`：`AppColors` 是 `0xFF000000`，HOCON 是 `#E6000000`；
- `labelSecondaryLight`：`AppColors` 是 `0x603C3C43`，HOCON 是 `#FF3C3C43`；
- `labelTertiaryLight`：`AppColors` 是 `0x303C3C43`，HOCON 是 `#803C3C43`；
- `AppColors` 没有 `background.transparent` 与 `gray-0/10/20/40/50`。

把 `useHardcoded` 切成 `true` 会改变文字颜色和透明度，不是“无文件模式的等价结果”。
修改颜色时若要同时维护兜底常量，需要手动同步并验证两种模式。

### 2.3 AppThemeConfig（运行时快照）

`AppThemeConfig` 是单套亮或暗调色板的快照，只包含 14 个颜色字段：
品牌色 3 个、背景色 3 个、gray `black` / `gray-30`、label 4 个、overlay 2 个。

```dart
final config = await ThemeLoader.loadThemeConfig(isDark: true);
Container(color: config.backgroundPrimary);
```

日常 UI 不建议直接使用它：直接在 Widget 中异步加载会绕开启动缓存，也拿不到
`styles.conf` 中的 Widget 布局样式。优先使用 `AppThemeData`。

---

## 3. 使用方式

### 3.1 跟随主题（推荐）

```dart
final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Container(
  color: theme.backgroundSecondary,
  child: Text(
    'Hello',
    style: TextStyle(color: theme.labelPrimary),
  ),
);
```

### 3.2 固定颜色

只有确实不随主题变化的场景才直接使用 `AppColors`：

```dart
Container(color: AppColors.brandPrimaryLight);
```

这类用法在暗色模式下不会自动换色，使用前确认视觉上可接受。

### 3.3 使用 const 常量

```dart
static const Color brandPrimary = Color(0xFF6200EE);
```

`const Color(0x...)` 是编译时常量，支持 Widget 树的 const 优化；
`Color.fromARGB(...)` 是运行时构造，不建议在常量定义中使用。

---

## 4. 添加新颜色

### 场景 A：只给 `styles.conf` 使用

1. 在 `colors.conf` 的对应调色板中添加 `light` / `dark`；
2. 在 `styles.conf` 中用引用取值，例如
   `${palettes.semantic.success.light}`；
3. 加载 dark 版 `styles.conf` 时引用会自动切换为 `.dark`，不需要写两套。

不需要改 Dart 代码。适合只用于某个 Widget 的背景、边框等布局样式。

### 场景 B：需要通过 `AppThemeData` 暴露给业务代码

按顺序修改：

1. `assets/themes/colors.conf`：添加颜色对；
2. `lib/core/theme/app_theme_config.dart`：加字段，并在 `fromJsonWithMode`、
   `copyWith` 中补上解析和拷贝；
3. `lib/core/theme/theme_data.dart`：在 `AppThemeData` 中加 getter，
   HOCON 分支读 `_config`，硬编码分支读 `AppColors`；
4. `lib/core/theme/app_colors.dart`：加 `Light` / `Dark` 兜底常量，
   保证 `useHardcoded == true` 和加载失败时仍可用；
5. 运行 `flutter test test/core/theme/`，并在亮 / 暗两种模式下各看一次效果。

`AppThemeConfig.fromJson` 只读取 `light` 值，实际应用走的是
`fromJsonWithMode`；新增字段时两个工厂都要改，否则某个入口会取不到颜色。

---

## 5. 最佳实践

### 5.1 优先使用 AppThemeData

需要跟随亮暗模式时：

```dart
final theme = AppTheme.fromBrightness(brightness);
Container(color: theme.backgroundPrimary);
```

不要手写 `brightness == Brightness.light ? ... : ...` 的三元表达式，
除非是在主题系统之外做一次性计算。

### 5.2 语义化命名

命名反映用途而不是颜色值：用 `labelPrimary`，不要用 `black95`；
用 `overlayDefault`，不要用 `black12`。

### 5.3 不要假设两套颜色自动同步

`colors.conf` 与 `app_colors.dart` 是两套独立定义。默认运行时使用前者，
后者只在兜底或显式切换时生效。当前两者已经存在差异（见 2.2），
新增或修改颜色时不要把“同步”当成自动行为。

### 5.4 用引用而不是复制色值

`styles.conf` 中引用 `${palettes...}`，不要在 Widget 样式里重复写十六进制色值，
否则调色板调整后会出现遗漏。

---

## 6. 相关文档

- [主题系统概述](./overview.md)
- [字体排版使用指南](./typography.md)
