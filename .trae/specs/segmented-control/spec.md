# Segmented Control 组件规范

## Why
需要实现 iOS 26 风格的 Segmented Control 组件，用于在多个视图间进行切换。该组件需支持灵活的按钮配置（文字、Lucide 图标、SVG 图标），以适配项目中不同的使用场景。

## What Changes
- 新增 `SegmentedControlButton` 组件，支持文字和图标（可选，图标在前文字在后）
- 新增 `SegmentedControl` 组件，接收按钮配置列表，渲染完整的 Segmented Control 容器
- 支持选中状态切换，通过回调通知选中索引
- 遵循 iOS 26 设计规范：圆角胶囊容器（100px）、内部按钮选中态白色圆角背景、未选中态透明背景

## Impact
- Affected specs: 无
- Affected code: 
  - `lib/presentation/widgets/organisms/segmented_control/segmented_control_button.dart`
  - `lib/presentation/widgets/organisms/segmented_control/segmented_control.dart`

## ADDED Requirements

### Requirement: SegmentedControlButton 组件
SegmentedControlButton  SHALL 提供可自定义文字和图标的按钮片段。

#### 场景: 仅显示文字
- **WHEN** 只传入 `label` 参数
- **THEN** 渲染仅包含文字的按钮片段

#### 场景: 仅显示图标
- **WHEN** 只传入 `icon` 参数
- **THEN** 渲染仅包含图标的按钮片段

#### 场景: 图标加文字
- **WHEN** 同时传入 `icon` 和 `label`
- **THEN** 图标在前、文字在后，水平排列渲染

### Requirement: SegmentedControl 组件
SegmentedControl SHALL 提供完整的 iOS 风格 Segmented Control 容器。

#### 场景: 渲染多个按钮
- **WHEN** 传入 `segments` 列表
- **THEN** 按顺序渲染所有按钮片段，按钮等宽分配

#### 场景: 切换选中状态
- **WHEN** 用户点击某个按钮
- **THEN** 该按钮显示选中态（白色圆角背景），并触发 `onTap` 回调传入选中索引

#### 场景: 默认选中
- **WHEN** 传入 `selectedIndex` 参数
- **THEN** 对应索引的按钮显示选中态

### Requirement: 视觉规范
组件 SHALL 遵循 iOS 26 设计规范。

#### 场景: 容器样式
- **THEN** 圆角 100px（胶囊形），padding 2px，gap 4px，高度 32px

#### 场景: 选中态样式
- **THEN** 白色圆角背景（圆角 20px），padding 6px 3px

#### 场景: 未选中态样式
- **THEN** 透明背景，padding 6px 3px

#### 场景: 文字样式
- **THEN** SF Pro Semibold，字号 13.3px，行高 18px，字间距 -0.08px
