# 字体排版使用指南

本文档详细介绍 TinyCast 字体排版系统的配置和使用方法。

---

## 1. 排版配置

### 1.1 HOCON 配置文件

字体排版定义位于 `assets/themes/typography.conf`：

```hocon
heading {
  # largetitle: 页面主标题
  largetitle {
    desktop {
      fontsize = "12"
      fontweight = "bold"
      lineheight = "16/12"
    }
    tablet {
      fontsize = "16"
      fontweight = "bold"
      lineheight = "16/12"
    }
    mobile {
      fontsize = "14"
      fontweight = "bold"
      lineheight = "14/12"
    }
  }
}
```

### 1.2 配置项说明

| 配置项 | 说明 | 示例值 |
|---|---|---|
| `fontsize` | 字号（pt） | `"16"` |
| `fontweight` | 字重 | `"bold"`, `"regular"`, `"semibold"` |
| `lineheight` | 行高（格式：`行高/字号`） | `"16/12"` |

### 1.3 响应式变体（desktop / tablet / mobile）

部分文字样式（如 `h3`、`caption`）支持按设备类型定义不同的排版参数。在 HOCON 中使用嵌套对象表达：

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

每个设备变体包含独立的 `fontsize`、`fontweight`、`lineheight`、`letterspacing` 配置，`color` 在顶层统一指定，引用 `colors.conf` 中的颜色 key。

目前支持响应式变体的样式：

| 样式名 | desktop | tablet | mobile |
|---|---|---|---|
| `h3` | 14pt / w500 | 22pt / w600 | 22pt / w600 |
| `caption` | 12pt / w400 | 12pt / w400 | 12pt / w400 |

---

## 2. Dart 文字样式

### 2.1 AppTextStyles 类

文字样式在 `lib/core/theme/app_text_styles.dart` 中定义：

```dart
class AppTextStyles {
  static const String _fontFamily = '.SF Pro Text';

  // H1 - 大标题
  static const TextStyle h1Light = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.2,
    color: AppColors.labelPrimaryLight,
  );

  static const TextStyle h1Dark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.2,
    color: AppColors.labelPrimaryDark,
  );

  // 更多样式...
}
```

### 2.2 文字样式速查

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

---

## 3. 使用方式

### 3.1 直接使用 AppTextStyles

```dart
Text('大标题', style: AppTextStyles.h1Light)
Text('正文', style: AppTextStyles.bodyMediumDark)
Text('注释', style: AppTextStyles.captionLight)
```

### 3.2 通过 AppThemeData（推荐）

自动跟随亮色/暗色切换：

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
    Text('正文内容很长...', style: theme.bodyLarge),
    SizedBox(height: theme.spacingXs),
    Text('注：这是补充说明', style: theme.caption),
  ],
)
```

### 3.3 自定义文字样式

基于已有样式进行微调：

```dart
final theme = AppTheme.light;

Text(
  '自定义样式',
  style: theme.bodyLarge.copyWith(
    color: theme.brandPrimary,
    fontWeight: FontWeight.w600,
  ),
)
```

---

## 4. 在 Widget 中组合使用

### 4.1 卡片示例

```dart
class ArticleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;

  const ArticleCard({
    required this.title,
    required this.subtitle,
    required this.content,
  });

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.h3),
          SizedBox(height: theme.spacingXs),
          Text(subtitle, style: theme.bodyMedium),
          SizedBox(height: theme.spacingSm),
          Text(content, style: theme.bodySmall),
        ],
      ),
    );
  }
}
```

### 4.2 列表项示例

```dart
class ListItem extends StatelessWidget {
  final String title;
  final String description;

  const ListItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.bodyLarge),
          SizedBox(height: theme.spacingXxs),
          Text(description, style: theme.bodySmall),
        ],
      ),
    );
  }
}
```

---

## 5. 添加新文字样式

### 步骤 1：在 typography.conf 中添加配置

```hocon
heading {
  title4 {
    desktop {
      fontsize = "14"
      fontweight = "regular"
      lineheight = "14/12"
    }
  }
}
```

### 步骤 2：在 app_text_styles.dart 中添加样式

```dart
class AppTextStyles {
  static const String _fontFamily = '.SF Pro Text';

  // ... 现有样式

  // H4 - 四级标题
  static const TextStyle h4Light = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.labelPrimaryLight,
  );

  static const TextStyle h4Dark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.labelPrimaryDark,
  );
}
```

### 步骤 3：在 AppThemeData 中添加 getter

```dart
// 在 lib/core/theme/theme_data.dart 的 AppThemeData 类中添加
TextStyle get h4 =>
    mode == AppThemeMode.light
        ? AppTextStyles.h4Light
        : AppTextStyles.h4Dark;
```

### 步骤 4：使用新样式

```dart
final theme = AppTheme.light;
Text('四级标题', style: theme.h4)
```

---

## 6. 最佳实践

### 6.1 统一使用 AppTextStyles 或 AppThemeData

**推荐**：
```dart
Text('标题', style: AppTheme.light.h1)
Text('正文', style: AppTextStyles.bodyLargeLight)
```

**不推荐**：
```dart
// 不要手动定义 TextStyle
Text('标题', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700))
```

### 6.2 优先使用 AppThemeData

当需要跟随主题切换时：

```dart
// 推荐：自动跟随
final theme = AppTheme.fromBrightness(brightness);
Text('标题', style: theme.h1)

// 不推荐：手动判断
Text(
  '标题',
  style: brightness == Brightness.light
      ? AppTextStyles.h1Light
      : AppTextStyles.h1Dark,
)
```

### 6.3 使用 copyWith 进行微调

```dart
// 推荐：基于已有样式修改
Text('红色正文', style: theme.bodyLarge.copyWith(color: theme.brandPrimary))

// 不推荐：从头定义
Text('红色正文', style: TextStyle(fontSize: 17, color: Color(0xFF6200EE)))
```
