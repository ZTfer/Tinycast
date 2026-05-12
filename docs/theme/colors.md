# 颜色系统使用指南

本文档详细介绍 TinyCast 颜色系统的配置、使用和扩展方法。

---

## 1. 颜色配置

### 1.1 HOCON 配置文件

颜色定义位于 `assets/themes/colors.conf`：

```hocon
{
  version = 0.1
  name = "Colors"

  palettes {
    # 品牌色
    brand {
      primary {
        light = "#FF6200EE"
        dark = "#FFBB86FC"
      }
    }
  }
}
```

### 1.2 颜色格式

使用 `#AARRGGBB` 格式（ARGB 十六进制）：
- `AA` = Alpha 透明度（00-FF）
- `RR` = 红色通道
- `GG` = 绿色通道
- `BB` = 蓝色通道

```hocon
primary {
  light = "#FF6200EE"   // 完全不透明，紫色
  dark = "#FFBB86FC"    // 完全不透明，浅紫色
}
label-primary {
  light = "#95000000"   // 95% 透明度黑色
  dark = "#95FFFFFF"    // 95% 透明度白色
}
```

### 1.3 调色板分类

| 调色板 | 颜色名 | 亮色值 | 暗色值 | 用途 |
|---|---|---|---|---|
| **brand** | primary | `#FF6200EE` | `#FFBB86FC` | 主品牌色（按钮、高亮） |
| | secondary | `#FF03DAC6` | `#FF03DAC6` | 辅助品牌色 |
| | blue | `#FF0088FF` | `#FF0091FF` | 蓝色强调色 |
| **background** | primary | `#FFFFFFFF` | `#FF000000` | 主背景 |
| | secondary | `#FFF2F2F7` | `#FF1C1C1E` | 次级背景（卡片） |
| | tertiary | `#FFFFFFFF` | `#FF2C2C2E` | 第三背景（对话框） |
| **gray** | black | `#FF000000` | `#FF000000` | 纯黑（阴影） |
| | gray-30 | `#30000000` | `#30FFFFFF` | 30% 透明灰（分隔线） |
| **label** | primary | `#95000000` | `#95FFFFFF` | 主要文字 |
| | secondary | `#603C3C43` | `#70EBEBF5` | 次要文字 |
| | tertiary | `#303C3C43` | `#30EBEBF5` | 辅助文字 |
| | quaternary | `#183C3C43` | `#16EBEBF5` | 占位文字 |
| **overlay** | default | `#20000000` | `#48000000` | 默认遮罩 |
| | transparent | `#00000000` | `#00FFFFFF` | 透明遮罩 |

---

## 2. Dart 颜色常量

### 2.1 AppColors 类

所有颜色在 `lib/core/theme/app_colors.dart` 中定义为 `const Color` 常量：

```dart
class AppColors {
  AppColors._();

  // 品牌色
  static const Color brandPrimaryLight = Color(0xFF6200EE);
  static const Color brandPrimaryDark = Color(0xFFBB86FC);

  // 背景色
  static const Color backgroundPrimaryLight = Color(0xFFFFFFFF);
  static const Color backgroundPrimaryDark = Color(0xFF000000);

  // 文字色
  static const Color labelPrimaryLight = Color(0x95000000);
  static const Color labelPrimaryDark = Color(0x95FFFFFF);
  // ... 更多颜色
}
```

### 2.2 命名规则

`{调色板}{颜色名}{主题}`，首字母大写驼峰命名：

| 调色板 | 颜色名 | 主题 | Dart 常量名 |
|---|---|---|---|
| brand | primary | Light | `brandPrimaryLight` |
| label | secondary | Dark | `labelSecondaryDark` |
| background | primary | Light | `backgroundPrimaryLight` |

---

## 3. 使用方式

### 3.1 直接使用颜色常量

适用于不需要跟随主题切换的固定颜色：

```dart
Container(
  color: AppColors.backgroundPrimaryLight,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.labelPrimaryDark),
  ),
)
```

### 3.2 通过 AppThemeData（推荐）

自动跟随亮色/暗色切换：

```dart
final theme = AppTheme.fromBrightness(
  MediaQuery.platformBrightnessOf(context),
);

Container(
  color: theme.backgroundPrimary,
  child: Text(
    'Hello',
    style: TextStyle(color: theme.labelPrimary),
  ),
)
```

### 3.3 通过 AppThemeConfig（运行时）

从 HOCON 文件动态加载：

```dart
// 方式 1：直接加载
final config = await ThemeLoader.loadThemeConfig(isDark: false);
Container(color: config.backgroundPrimary)

// 方式 2：通过 Riverpod Provider
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return themeState.when(
      data: (state) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final config = state.forBrightness(brightness);

        return Container(color: config.backgroundPrimary);
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => const Text('主题加载失败'),
    );
  }
}
```

---

## 4. 添加新颜色

### 步骤 1：修改 colors.conf

在 `assets/themes/colors.conf` 中添加新颜色：

```hocon
palettes {
  semantic {
    success {
      light = "#FF34C759"
      dark = "#FF30D158"
    }
    error {
      light = "#FFFF3B30"
      dark = "#FFFF453A"
    }
    warning {
      light = "#FFFF9500"
      dark = "#FFFF9F0A"
    }
  }
}
```

### 步骤 2：在 app_colors.dart 中添加常量

```dart
class AppColors {
  // ... 现有颜色

  // 新增语义色
  static const Color semanticSuccessLight = Color(0xFF34C759);
  static const Color semanticSuccessDark = Color(0xFF30D158);
  static const Color semanticErrorLight = Color(0xFFFF3B30);
  static const Color semanticErrorDark = Color(0xFFFF453A);
  static const Color semanticWarningLight = Color(0xFFFF9500);
  static const Color semanticWarningDark = Color(0xFFFF9F0A);
}
```

### 步骤 3（可选）：在 AppThemeData 中添加 getter

```dart
// 在 lib/core/theme/theme_data.dart 的 AppThemeData 类中添加
Color get semanticSuccess =>
    mode == AppThemeMode.light
        ? AppColors.semanticSuccessLight
        : AppColors.semanticSuccessDark;

Color get semanticError =>
    mode == AppThemeMode.light
        ? AppColors.semanticErrorLight
        : AppColors.semanticErrorDark;
```

### 步骤 4：使用新颜色

```dart
// 方式一：直接使用常量
Icon(Icons.check, color: AppColors.semanticSuccessLight)

// 方式二：通过 AppThemeData（自动跟随主题）
final theme = AppTheme.light;
Icon(Icons.check, color: theme.semanticSuccess)
```

---

## 5. 最佳实践

### 5.1 始终使用主题系统

**推荐**：
```dart
Text('标题', style: TextStyle(color: AppTheme.light.labelPrimary))
Container(color: AppColors.backgroundPrimaryLight)
```

**不推荐**：
```dart
// 不要硬编码颜色值
Text('标题', style: TextStyle(color: Color(0xFF000000)))
```

### 5.2 使用 const Color(0x...) 格式

```dart
// 推荐：使用 const，编译器优化
static const Color brandPrimary = Color(0xFF6200EE);

// 不推荐：使用 Color.fromARGB，性能较差
static final Color brandPrimary = Color.fromARGB(255, 98, 0, 238);
```

`const Color(0x...)` 的优势：
- 编译时常量，零运行时开销
- 支持 Widget 树的 const 优化
- 与 HOCON 格式直接对应，易于维护

### 5.3 使用语义化命名

颜色命名应反映**用途**而非**颜色本身**：

```dart
// 推荐：labelPrimary 表示主要文字颜色
static const Color labelPrimaryLight = Color(0x95000000);

// 不推荐：black95 只是描述了颜色值
static const Color black95 = Color(0x95000000);
```

### 5.4 优先使用 AppThemeData

当 Widget 需要根据主题自动切换时：

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

### 5.5 HOCON 与 Dart 保持一致

每次修改 `colors.conf` 后，必须同步更新 `app_colors.dart`。建议：
- 保持命名规则一致
- 确保 ARGB 格式完全对应
- 不要遗漏任何 light/dark 配对
