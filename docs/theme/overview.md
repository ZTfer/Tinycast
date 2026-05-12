# 主题系统概述

本文档介绍 TinyCast 项目的自定义主题系统架构和使用方法。

---

## 1. 设计原则

TinyCast 采用了一套**独立于 Material Design** 的主题系统，核心设计思想如下：

- **HOCON 驱动**：所有配置在 `assets/themes/` 下的 `.conf` 文件中定义，支持注释，易于维护
- **亮色/暗色双调色板**：每个颜色同时定义 light 和 dark 两个变体
- **编译时常量**：Dart 侧使用 `const Color(0x...)` 格式，保证性能
- **统一访问入口**：通过 `AppTheme` 类统一获取主题相关的颜色、文字样式、间距、圆角和阴影

### 为什么不用 Material ThemeData？

Material 的 `ThemeData` 耦合了大量我们不需要的组件样式（如 FAB、SnackBar、Chip 等）。自定义主题系统提供了更精细的控制权，同时保持了代码的简洁性。

---

## 2. 文件结构

```
assets/themes/
├── colors.conf        # 颜色配置（HOCON 格式）
└── typography.conf    # 字体排版配置（HOCON 格式）

lib/core/theme/
├── app_colors.dart        # 颜色常量定义（编译时常量）
├── app_text_styles.dart   # 文字样式定义
├── app_theme_config.dart  # 运行时主题配置类
├── app_theme.dart         # 主题访问入口
├── theme_data.dart        # AppThemeData 类 + 间距 + 圆角 + 阴影
└── theme_loader.dart      # HOCON 文件加载器

lib/core/providers/
└── theme_provider.dart    # Riverpod 主题状态管理
```

---

## 3. HOCON 配置文件

### 3.1 colors.conf

颜色定义位于 `assets/themes/colors.conf`，采用嵌套对象语法：

```hocon
palettes {
  brand {
    primary {
      light = "#FF6200EE"
      dark = "#FFBB86FC"
    }
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

### 3.2 typography.conf

字体排版定义位于 `assets/themes/typography.conf`，采用嵌套对象语法：

```hocon
heading {
  largetitle {
    desktop {
      fontsize = "12"
      fontweight = "bold"
      lineheight = "16/12"
    }
  }
}
```

---

## 4. HOCON 解析器

`ThemeLoader` 内置轻量级 HOCON 解析器，支持：

- `#` 和 `//` 单行注释
- 嵌套对象语法 `key { sub { value = "x" } }`
- 点号路径 `key.sub.value = "x"`

---

## 5. 双模式：编译时常量 vs 运行时解析

### 模式 A：编译时常量（推荐日常使用）

颜色定义为 `const Color`，性能最优，支持 Widget 树的 const 优化。

```dart
Container(color: AppColors.backgroundPrimaryLight)
```

### 模式 B：运行时 JSON 解析（适合动态换肤）

通过 `ThemeLoader` 或 `themeProvider` 从 HOCON 加载颜色，支持远程配置。

```dart
final config = await ThemeLoader.loadThemeConfig(isDark: false);
Container(color: config.backgroundPrimary)
```

---

## 6. 快速上手

```dart
import 'package:your_app/core/theme/app_theme.dart';
import 'package:your_app/core/theme/app_colors.dart';

// 获取当前主题
final theme = AppTheme.fromBrightness(MediaQuery.platformBrightnessOf(context));

// 使用颜色
Container(color: theme.backgroundPrimary)

// 使用文字样式
Text('标题', style: theme.h1)

// 使用间距
SizedBox(height: theme.spacingMd)
```

---

## 7. 相关文档

- [颜色系统使用指南](./colors.md)
- [字体排版使用指南](./typography.md)
