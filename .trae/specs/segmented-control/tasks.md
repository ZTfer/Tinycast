# Tasks
- [ ] Task 1: 实现 SegmentedControlButton 组件
  - [ ] SubTask 1.1: 创建 SegmentedControlButton 类，继承 StatelessWidget
  - [ ] SubTask 1.2: 实现 label 参数（可选文字）
  - [ ] SubTask 1.3: 实现 icon 参数（可选 Widget 类型图标，支持 Lucide/SVG）
  - [ ] SubTask 1.4: 实现 isSelected 参数控制选中态样式
  - [ ] SubTask 1.5: 实现 onTap 回调参数
  - [ ] SubTask 1.6: 实现图标在前、文字在后的水平布局（Row）
  - [ ] SubTask 1.7: 实现 iOS 26 规范的样式：选中态白色圆角背景、未选中态透明背景、SF Pro 字体

- [ ] Task 2: 实现 SegmentedControl 组件
  - [ ] SubTask 2.1: 创建 SegmentedControl 类，继承 StatelessWidget
  - [ ] SubTask 2.2: 实现 segments 参数（List<SegmentedControlButton>）
  - [ ] SubTask 2.3: 实现 selectedIndex 参数（默认选中索引）
  - [ ] SubTask 2.4: 实现 onTap 回调（返回选中索引）
  - [ ] SubTask 2.5: 实现胶囊形容器样式：圆角 100px、padding 2px、gap 4px、高度 32px
  - [ ] SubTask 2.6: 实现按钮等宽分配（Expanded）
  - [ ] SubTask 2.7: 将 isSelected 状态传递给子按钮组件

# Task Dependencies
- [Task 2] 依赖 [Task 1]
