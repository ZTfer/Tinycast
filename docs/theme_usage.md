# 主题系统使用文档

本文档介绍 TinyCast 项目基于 JSON 的自定义主题系统。该系统**不使用 Flutter Material 的 `ThemeData`**，而是通过自定义的 `AppThemeData` 类和 JSON 配置文件实现主题管理。

---

## 1. 概述

TinyCast 采用了一套**独立于 Material Design** 的主题系统，核心设计思想如下：

- **JSON 驱动**：所有颜色定义在 `assets/themes/colors.json` 中，便于维护和切换
- **亮色/暗色双调色板**：每个颜色同时定义 light 和 dark 两个变体
- **编译时常量**：Dart 侧使用 `const Color(0x...)` 格式，保证性能
- **统一访问入口**：通过 `AppTheme` 类统一获取主题相关的颜色、文字样式、间距、圆角和阴影

### 为什么不用 Material ThemeData？

Material 的 `ThemeData` 耦合了大量我们不需要的组件样式（如 FAB、SnackBar、Chip 等）。自定义主题系统提供了更精细的控制权，同时保持了代码的简洁性。

---

## 2. JSON 文件结构

颜色定义位于 `assets/themes/colors.json`，采用分层调色板结构：

```json
{
  "version": 1.0,
  "palettes": {
    "品牌色": {
      "颜色名": {
        "light": "#AARRGGBB",
        "dark": "#AARRGGBB"
      }
    },
    "功能色": { ... },
    "文字色": { ... }
  }
}
```

### 调色板分类

| 调色板 (palette) | 颜色名 (name) | 用途 |
|---|---|---|
| **brand** | `primary` | 主品牌色（强调色） |
| | `secondary` | 辅助品牌色 |
| | `blue` | 蓝色品牌色 |
| **background** | `primary` | 主背景色 |
| | `secondary` | 次级背景色（卡片、侧栏等） |
| | `tertiary` | 第三级背景色 |
| **gray** | `black` | 纯黑色 |
| | `gray-30` | 30% 透明度灰色（分割线等） |
| **label** | `primary` | 主要文字（标题、正文） |
| | `secondary` | 次要文字（描述、副标题） |
| | `tertiary` | 第三级文字（提示、占位符） |
| | `quaternary` | 第四级文字（最弱层级） |
| **overlay** | `default` | 默认遮罩层 |
| | `transparent` | 透明遮罩层 |

### 颜色格式

颜色使用 `#AARRGGBB` 格式（ARGB 十六进制），其中：
- `AA` = Alpha 透明度（00-FF）
- `RR` = 红色通道
- `GG` = 绿色通道
- `BB` = 蓝色通道

```json
{
  "primary": {
    "light": "#FF6200EE",
    "dark": "#FFBB86FC"
  }
}
```

> 注意：JSON 中的颜色值包含 `FF` 前缀（Alpha 通道），转换为 Dart `Color` 时直接使用 `0x` 替换 `#`。

### 新增调色板示例

如果要添加一组语义色（如 success、error、warning）：

```json
{
  "palettes": {
    "semantic": {
      "success": {
        "light": "#FF34C759",
        "dark": "#FF30D158"
      },
      "error": {
        "light": "#FFFF3B30",
        "dark": "#FFFF453A"
      },
      "warning": {
        "light": "#FFFF9500",
        "dark": "#FFFF9F0A"
      }
    }
  }
}
```

---

## 3. 主题架构

所有主题相关文件位于 `lib/core/theme/` 目录下：

```
lib/core/theme/
├── app_colors.dart        # 颜色常量定义
├── app_text_styles.dart   # 文字样式定义
├── app_theme.dart         # 主题访问入口
├── theme_data.dart        # AppThemeData 类 + 间距 + 圆角 + 阴影
└── theme_loader.dart      # JSON 文件加载器
```

### 3.1 `theme_loader.dart` — JSON 解析器

负责从 `assets/themes/colors.json` 读取并缓存 JSON 数据：

```dart
class ThemeLoader {
  static const String _themePath = 'assets/themes/colors.json';
  static Map<String, dynamic>? _cachedJson;

  static Future<Map<String, dynamic>> load() async { ... }
  static String getLightColor(Map<String, dynamic> json, String palette, String name) { ... }
  static String getDarkColor(Map<String, dynamic> json, String palette, String name) { ... }
  static void clearCache() { ... }
}
```

- 使用 `rootBundle.loadString` 加载 JSON
- 内置缓存机制，避免重复读取
- `clearCache()` 用于热重载时清除缓存

### 3.2 `app_colors.dart` — 颜色常量

将 JSON 中的颜色转换为 Dart `const Color` 常量：

```dart
class AppColors {
  AppColors._();

  static const Color brandPrimaryLight = Color(0xFFFF6200EE);
  static const Color brandPrimaryDark = Color(0xFFFFBB86FC);
  static const Color labelPrimaryLight = Color(0x95000000);
  static const Color labelPrimaryDark = Color(0x95FFFFFF);
  // ... 更多颜色
}
```

**命名规则**：`{调色板}{颜色名}{主题}`，首字母大写驼峰命名。

例如：
- `brand` + `primary` + `Light` → `brandPrimaryLight`
- `label` + `secondary` + `Dark` → `labelSecondaryDark`
- `background` + `primary` + `Light` → `backgroundPrimaryLight`

### 3.3 `app_text_styles.dart` — 文字样式

定义了完整的排版系统，使用 `.SF Pro Text` 字体：

| 样式名 | 字号 | 字重 | 行高 | 字间距 | 用途 |
|---|---|---|---|---|---|
| `h1` | 34 | w700 (Bold) | 1.2 | 0.37 | 大标题 |
| `h2` | 28 | w700 (Bold) | 1.2 | 0.35 | 中标题 |
| `h3` | 22 | w600 (SemiBold) | 1.3 | 0.35 | 小标题 |
| `bodyLarge` | 17 | w400 (Regular) | 1.5 | -0.41 | 大正文 |
| `bodyMedium` | 15 | w400 (Regular) | 1.4 | -0.24 | 标准正文 |
| `bodySmall` | 13 | w400 (Regular) | 1.4 | -0.08 | 小正文 |
| `caption` | 12 | w400 (Regular) | 1.3 | 0 | 注释、说明文字 |
| `button` | 17 | w600 (SemiBold) | 1.3 | -0.41 | 按钮文字 |

每个样式都有 `Light` 和 `Dark` 两个变体，自动使用对应主题的文字颜色。

### 3.4 `theme_data.dart` — 核心主题类

包含四个部分：

#### AppThemeMode 枚举

```dart
enum AppThemeMode { light, dark }
```

#### AppSpacing — 间距系统

```dart
class AppSpacing {
  static const double xxs = 4;   // 超小间距
  static const double xs  = 8;   // 小间距
  static const double sm  = 12;  // 中小间距
  static const double md  = 16;  // 标准间距
  static const double lg  = 24;  // 大间距
  static const double xl  = 32;  // 超大间距
  static const double xxl = 48;  // 最大间距
}
```

#### AppBorderRadius — 圆角系统

```dart
class AppBorderRadius {
  static const double xs   = 4;     // 极小圆角
  static const double sm   = 8;     // 小圆角
  static const double md   = 12;    // 标准圆角
  static const double lg   = 16;    // 大圆角
  static const double xl   = 24;    // 超大圆角
  static const double full = 9999;  // 完全圆形
}
```

#### AppShadows — 阴影系统

```dart
class AppShadows {
  static const List<BoxShadow> sm = [...];  // 小阴影（卡片悬浮）
  static const List<BoxShadow> md = [...];  // 中阴影（弹出菜单）
  static const List<BoxShadow> lg = [...];  // 大阴影（模态框）
}
```

#### AppThemeData — 主题数据类

统一聚合颜色、文字样式、间距、圆角和阴影的访问：

```dart
class AppThemeData {
  final AppThemeMode mode;
  const AppThemeData({required this.mode});

  // 颜色 getters
  Color get backgroundPrimary => ...
  Color get labelPrimary => ...
  Color get brandPrimary => ...

  // 文字样式 getters
  TextStyle get h1 => ...
  TextStyle get bodyLarge => ...

  // 间距 getters
  double get spacingMd => AppSpacing.md;

  // 圆角 getters
  double get borderRadiusSm => AppBorderRadius.sm;

  // 阴影 getters
  List<BoxShadow> get shadowMd => AppShadows.md;
}
```

### 3.5 `app_theme.dart` — 入口文件

提供简洁的 API 访问亮色和暗色主题：

```dart
class AppTheme {
  AppTheme._();

  static AppThemeData get light => const AppThemeData(mode: AppThemeMode.light);
  static AppThemeData get dark => const AppThemeData(mode: AppThemeMode.dark);

  static AppThemeData fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
```

---

## 4. 使用示例

### 4.1 直接访问颜色常量

适用于不需要跟随主题切换的固定颜色：

```dart
Container(
  color: AppColors.backgroundPrimaryLight,  // 亮色主背景
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.labelPrimaryDark),  // 暗色主文字
  ),
)
```

**完整颜色列表**：

| 常量名 | 亮色值 | 暗色值 |
|---|---|---|
| `brandPrimaryLight/Dark` | `#FF6200EE` | `#FFBB86FC` |
| `brandSecondaryLight/Dark` | `#FF03DAC6` | `#FF03DAC6` |
| `brandBlueLight/Dark` | `#FF0088FF` | `#FF0091FF` |
| `backgroundPrimaryLight/Dark` | `#FFFFFFFF` | `#FF000000` |
| `backgroundSecondaryLight/Dark` | `#FFF2F2F7` | `#FF1C1C1E` |
| `backgroundTertiaryLight/Dark` | `#FFFFFFFF` | `#FF2C2C2E` |
| `labelPrimaryLight/Dark` | `95% 黑` | `95% 白` |
| `labelSecondaryLight/Dark` | `60% #3C3C43` | `70% #EBEBF5` |
| `labelTertiaryLight/Dark` | `30% #3C3C43` | `30% #EBEBF5` |
| `labelQuaternaryLight/Dark` | `18% #3C3C43` | `16% #EBEBF5` |
| `overlayDefaultLight/Dark` | `20% 黑` | `48% 黑` |
| `overlayTransparentLight/Dark` | `#00000000` | `#00FFFFFF` |
| `grayBlackLight/Dark` | `#FF000000` | `#FF000000` |
| `gray30Light/Dark` | `30% 黑` | `30% 白` |

### 4.2 使用 AppThemeData（推荐）

推荐方式：通过 `AppTheme` 获取主题数据，自动跟随亮色/暗色切换：

```dart
// 获取当前主题
final theme = AppTheme.fromBrightness(MediaQuery.platformBrightnessOf(context));

// 或者直接使用 light/dark
final lightTheme = AppTheme.light;
final darkTheme = AppTheme.dark;
```

#### 获取颜色

```dart
final theme = AppTheme.light;

Container(
  color: theme.backgroundPrimary,
  child: Text(
    '标题',
    style: theme.h1,
  ),
)
```

#### 获取文字样式

```dart
final theme = AppTheme.dark;

Text(
  '大标题',
  style: theme.h1,
);

Text(
  '正文内容',
  style: theme.bodyLarge,
);

Text(
  '小标题',
  style: theme.h3,
);

Text(
  '注释文字',
  style: theme.caption,
);
```

#### 获取间距

```dart
final theme = AppTheme.light;

Padding(
  padding: EdgeInsets.all(theme.spacingMd),  // 16
  child: Row(
    children: [
      SizedBox(width: theme.spacingSm),  // 12
      SizedBox(height: theme.spacingLg), // 24
    ],
  ),
)
```

#### 获取圆角

```dart
final theme = AppTheme.light;

Container(
  decoration: BoxDecoration(
    color: theme.backgroundSecondary,
    borderRadius: BorderRadius.circular(theme.borderRadiusMd),  // 12
  ),
)

// 圆形头像
ClipOval(
  child: Image.asset('avatar.png'),
)

// 完全圆角（药丸形按钮）
Container(
  decoration: BoxDecoration(
    color: theme.brandPrimary,
    borderRadius: BorderRadius.circular(theme.borderRadiusFull),  // 9999
  ),
)
```

#### 获取阴影

```dart
final theme = AppTheme.light;

Container(
  decoration: BoxDecoration(
    color: theme.backgroundPrimary,
    borderRadius: BorderRadius.circular(theme.borderRadiusMd),
    boxShadow: theme.shadowMd,  // 中等阴影
  ),
)

// 小阴影（卡片）
boxShadow: theme.shadowSm

// 大阴影（弹出框）
boxShadow: theme.shadowLg
```

### 4.3 直接使用 AppSpacing / AppBorderRadius / AppShadows

如果不需要跟随主题，可以直接使用静态常量：

```dart
// 间距
SizedBox(width: AppSpacing.md)
Padding(padding: EdgeInsets.all(AppSpacing.xs))

// 圆角
BorderRadius.circular(AppBorderRadius.sm)

// 阴影
boxShadow: AppShadows.lg
```

### 4.4 在 Widget 中组合使用

```dart
class EpisodeCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const EpisodeCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.backgroundSecondary,
        borderRadius: BorderRadius.circular(theme.borderRadiusMd),
        boxShadow: theme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.h3,
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            subtitle,
            style: theme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

---

## 5. 添加新颜色

### 步骤 1：修改 colors.json

在 `assets/themes/colors.json` 中添加新的颜色条目：

```json
{
  "palettes": {
    "semantic": {
      "success": {
        "light": "#FF34C759",
        "dark": "#FF30D158"
      }
    }
  }
}
```

### 步骤 2：在 app_colors.dart 中添加对应常量

打开 `lib/core/theme/app_colors.dart`，添加对应的 `const Color` 定义：

```dart
// 新增语义色
static const Color semanticSuccessLight = Color(0xFF34C759);
static const Color semanticSuccessDark = Color(0xFF30D158);
```

### 步骤 3（可选）：在 AppThemeData 中添加 getter

如果该颜色需要根据主题自动切换，在 `lib/core/theme/theme_data.dart` 的 `AppThemeData` 类中添加 getter：

```dart
Color get semanticSuccess =>
    mode == AppThemeMode.light
        ? AppColors.semanticSuccessLight
        : AppColors.semanticSuccessDark;
```

### 步骤 4：使用新颜色

```dart
// 方式一：直接使用颜色常量
Icon(Icons.check, color: AppColors.semanticSuccessLight)

// 方式二：通过 AppThemeData（自动跟随主题）
final theme = AppTheme.light;
Icon(Icons.check, color: theme.semanticSuccess)
```

---

## 6. 最佳实践

### 6.1 始终使用主题系统

**推荐**：

```dart
Text('标题', style: AppTheme.light.h1)
Container(color: AppColors.backgroundPrimaryLight)
SizedBox(height: AppSpacing.md)
```

**不推荐**：

```dart
// 不要硬编码颜色值
Text('标题', style: TextStyle(color: Color(0xFF000000)))

// 不要使用魔法数字
SizedBox(height: 16)
Container(padding: EdgeInsets.all(8))
```

### 6.2 使用 const Color(0x...) 格式

```dart
// 推荐：使用 const，编译器优化
static const Color brandPrimary = Color(0xFFFF6200EE);

// 不推荐：使用 Color.fromARGB，性能较差
static final Color brandPrimary = Color.fromARGB(255, 98, 0, 238);
```

`const Color(0x...)` 的优势：
- 编译时常量，零运行时开销
- 支持 Widget 树的 const 优化
- 与 JSON 格式直接对应，易于维护

### 6.3 优先使用 AppThemeData

当 Widget 需要根据主题自动切换时，使用 `AppThemeData`：

```dart
// 推荐：自动跟随亮色/暗色
final theme = AppTheme.fromBrightness(brightness);
Container(color: theme.backgroundPrimary)

// 不推荐：需要手动判断
Container(
  color: brightness == Brightness.light
      ? AppColors.backgroundPrimaryLight
      : AppColors.backgroundPrimaryDark,
)
```

### 6.4 使用语义化命名

颜色命名应反映**用途**而非**颜色本身**：

```dart
// 推荐：labelPrimary 表示主要文字颜色
static const Color labelPrimaryLight = Color(0x95000000);

// 不推荐：black95 只是描述了颜色值
static const Color black95 = Color(0x95000000);
```

### 6.5 统一使用间距系统

```dart
// 推荐：使用 AppSpacing
SizedBox(height: AppSpacing.md)
Padding(padding: EdgeInsets.all(AppSpacing.sm))

// 不推荐：硬编码数字
SizedBox(height: 16)
Padding(padding: EdgeInsets.all(12))
```

### 6.6 文字样式统一使用 AppTextStyles 或 AppThemeData

```dart
// 推荐
Text('标题', style: AppTheme.light.h1)
Text('正文', style: AppTextStyles.bodyLargeLight)

// 不推荐：手动定义 TextStyle
Text('标题', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700))
```

### 6.7 JSON 与 Dart 保持一致

每次修改 `colors.json` 后，必须同步更新 `app_colors.dart`。建议：
- 保持命名规则一致
- 确保 ARGB 格式完全对应
- 不要遗漏任何 light/dark 配对

---

## 7. 文件引用速查

| 文件 | 路径 | 职责 |
|---|---|---|
| colors.json | `assets/themes/colors.json` | 颜色 JSON 源文件 |
| theme_loader.dart | `lib/core/theme/theme_loader.dart` | JSON 加载与缓存 |
| app_colors.dart | `lib/core/theme/app_colors.dart` | Color 常量定义 |
| app_text_styles.dart | `lib/core/theme/app_text_styles.dart` | 文字样式定义 |
| theme_data.dart | `lib/core/theme/theme_data.dart` | AppThemeData + Spacing + BorderRadius + Shadows |
| app_theme.dart | `lib/core/theme/app_theme.dart` | 主题访问入口 |
