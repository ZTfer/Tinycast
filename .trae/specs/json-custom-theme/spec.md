# JSON-Based Custom Theme System Spec

## Why
当前应用使用 Material Design 主题系统，颜色硬编码在 Dart 代码中，难以维护和扩展。需要改用 JSON 文件定义主题（颜色、字号等），并通过自定义 Widget 创建主题，完全脱离 Material 主题系统，实现更灵活、可控的样式管理。

## What Changes
- **重构** `lib/core/theme/app_colors.dart`：从 JSON 文件解析颜色数据，提供可通过 Dart 调用的颜色常量
- **重构** `lib/core/theme/app_theme.dart`：不再使用 `ThemeData`，改为提供自定义主题数据类，包含颜色、字号、圆角等设计令牌
- **新增** JSON 解析器：负责从 `assets/themes/` 加载和解析主题 JSON 文件
- **新增** 主题扩展支持：预留字号 JSON (`typography.json`) 等其他主题配置文件的解析能力
- **BREAKING**：移除对 `Theme.of(context)` 的依赖，改用自定义主题获取方式
- **新增** 使用文档：在 `docs/` 文件夹中添加主题使用指南

## Impact
- 影响模块：主题系统、颜色管理
- 影响文件：
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_theme.dart`
  - `assets/themes/colors.json`
- 新增文件：
  - `lib/core/theme/theme_data.dart`（自定义主题数据类）
  - `lib/core/theme/theme_loader.dart`（JSON 加载器）
  - `lib/core/theme/app_text_styles.dart`（字号样式定义）
  - `docs/theme_usage.md`（使用文档）

## ADDED Requirements

### Requirement: JSON Theme Loading
系统 SHALL 从 `assets/themes/` 目录加载和解析 JSON 主题文件，支持 light/dark 双模式颜色定义。

#### Scenario: 成功加载颜色 JSON
- **WHEN** 应用启动时
- **THEN** 系统解析 `colors.json` 并生成可在 Dart 中直接使用的颜色对象

### Requirement: Custom Theme Data Class
系统 SHALL 提供自定义主题数据类（不依赖 `ThemeData`），包含颜色、字号、圆角等设计令牌。

#### Scenario: 访问主题颜色
- **WHEN** 开发者需要获取颜色
- **THEN** 可通过 `AppTheme.colors.labelPrimary` 等方式访问

### Requirement: Color Constant Usage
颜色在使用时 SHALL 统一使用 `const Color(0xFFFFFFFF)` 格式，确保编译时常量性能优化。

#### Scenario: 使用预定义颜色
- **WHEN** 在 Widget 中设置颜色
- **THEN** 使用 `color: AppColors.brandPrimary` 等常量形式

### Requirement: Typography Support
系统 SHALL 支持从 JSON 定义字号、字重等排版属性。

#### Scenario: 定义字号体系
- **WHEN** 创建 `typography.json`（可选）
- **THEN** 系统解析并提供 `AppTextStyles.titleLarge` 等样式对象

## MODIFIED Requirements

### Requirement: Theme Architecture
当前使用 Material `ThemeData` 的方式 SHALL 改为自定义主题架构，不再依赖 `Theme.of(context)`。

**Migration**: 
- 移除 `ThemeData` 相关代码
- 使用 `AppTheme` 静态类直接访问设计令牌
- 所有颜色使用 `const Color(0x...)` 格式

## REMOVED Requirements

### Requirement: Material Theme Integration
不再使用 Material Design 主题系统。

**Reason**: 用户要求使用自定义 Widget 创建主题，而非 Material 主题。
**Migration**: 保留 `ThemeData` 作为兼容层（可选），但主要使用自定义主题数据类。
