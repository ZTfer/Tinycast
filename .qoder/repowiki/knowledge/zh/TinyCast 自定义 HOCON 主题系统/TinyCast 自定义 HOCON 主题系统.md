---
kind: frontend_style
name: TinyCast 自定义 HOCON 主题系统
category: frontend_style
scope:
    - '**'
source_files:
    - assets/themes/colors.conf
    - assets/themes/typography.conf
    - assets/themes/styles.conf
    - lib/core/theme/app_colors.dart
    - lib/core/theme/app_text_styles.dart
    - lib/core/theme/app_theme.dart
    - lib/core/theme/theme_loader.dart
    - lib/core/theme/theme_loader.dart
    - docs/theme/overview.md
    - docs/theme/colors.md
    - docs/theme/typography.md
---

## 系统概述

TinyCast 采用了一套**独立于 Material Design 的自定义主题系统**，通过 HOCON（Human-Optimized Config Object Notation）配置文件驱动颜色、排版和组件样式，实现亮色/暗色双模式切换与跨平台一致的视觉体验。

## 核心架构

### 配置层（HOCON 文件）
- **colors.conf**：定义品牌色、背景色、文字色、遮罩层等调色板，每个颜色同时包含 light/dark 两个变体
- **typography.conf**：定义 h1-h3、bodyLarge/Medium/Small、caption、button 等文本样式，支持 desktop/tablet/mobile 响应式变体
- **styles.conf**：整合 colors + typography，定义具体 Widget 样式（如 episode_item、mini_player、home_toolbar 等），使用 `${}` 引用语法组合其他配置

### Dart 常量层
- **app_colors.dart**：将 HOCON 中的颜色映射为 `const Color(0x...)` 编译时常量，命名规则 `{调色板}{颜色名}{Light/Dark}`
- **app_text_styles.dart**：预定义的 TextStyle 常量，包含多语言字体回退链（PingFang SC、Noto Sans CJK、Roboto、SF Pro 等）
- **theme_data.dart**：AppThemeData 类统一暴露颜色、间距、圆角、阴影和 Widget 样式访问入口

### 运行时加载层
- **theme_loader.dart**：内置轻量级 HOCON 解析器，支持注释、嵌套对象、include 引用、`${}` 变量替换
- **theme_provider.dart**：基于 Riverpod 的主题状态管理，支持从本地文件或远程 JSON 动态加载主题
- **app_theme.dart**：静态入口，根据 Brightness 自动选择 light/dark 主题

## 设计原则

1. **HOCON 驱动**：所有视觉配置集中在 `assets/themes/` 下的 `.conf` 文件中，支持注释，易于维护
2. **双调色板**：每个颜色同时定义 light 和 dark 变体，自动跟随系统主题切换
3. **编译时常量优先**：Dart 侧使用 `const Color(0x...)` 格式，保证性能并支持 Widget 树 const 优化
4. **统一访问入口**：通过 AppTheme 类统一获取主题相关的所有资源
5. **响应式设计**：部分样式支持按设备类型（desktop/tablet/mobile）定义不同参数

## 组件库结构

presentation/widgets 采用原子-分子-有机体（Atomic-Molecular-Organism）组织方式：
- **atoms/**：基础按钮、输入框、复选框等原子组件
- **molecules/**：由原子组合而成的复合组件（如 episode_item、breadcrumb）
- **organisms/**：复杂业务组件（如 mini_player、sidebar、navbar、tabbar）

## 图标与资源
- 使用 **lucide_icons_flutter** 作为主要图标库
- **flutter_svg** 渲染 SVG 图标
- **assets/gravity_icons/** 包含大量业务 SVG 图标
- **assets/images/** 存放应用图片资源

## 约束与规范
- 颜色必须使用 `#AARRGGBB` ARGB 十六进制格式
- 新增颜色需同步更新 colors.conf 和 app_colors.dart
- 禁止在组件中硬编码颜色值，必须通过 AppTheme 或 AppColors 访问
- 文字样式优先使用 copyWith 进行微调，避免重复定义 TextStyle
- 推荐使用 AppThemeData 而非直接判断亮度手动切换主题