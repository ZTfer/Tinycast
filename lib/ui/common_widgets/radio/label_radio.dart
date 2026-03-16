import 'package:flutter/material.dart';

/// 单选框组件
///
/// 用于显示可点击的单选框和文本标签，支持选中/未选中状态切换。
/// 包含悬停和选中状态的视觉反馈。
///
/// 功能特性：
/// - 支持选中/未选中状态切换
/// - 悬停时显示视觉反馈
/// - 选中时显示内部圆点
/// - 使用动画过渡效果
/// - 自定义边框颜色
class LabelRadio extends StatefulWidget {
  /// 单选框是否被选中
  final bool value;

  /// 单选框显示的文本标签
  final String label;

  /// 单选框状态改变时的回调函数
  ///
  /// 参数为新的选中状态（true 表示选中，false 表示未选中）
  final ValueChanged<bool> onChanged;

  const LabelRadio({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<LabelRadio> createState() => _RadioState();
}

class _RadioState extends State<LabelRadio> {
  /// 鼠标是否悬停在单选框上
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // 鼠标进入时设置悬停状态为 true
      onEnter: (_) => setState(() => _isHovering = true),
      // 鼠标离开时设置悬停状态为 false
      onExit: (_) => setState(() => _isHovering = false),
      // 悬停时显示点击光标
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // 点击时触发回调，将状态设置为选中（true）
        onTap: () => widget.onChanged(true),
        child: AnimatedContainer(
          // 悬停时有 200ms 的动画时长，否则无动画
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          // 水平和垂直内边距
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          // 容器装饰：圆角
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
          child: Row(
            // 主轴尺寸最小，根据内容自适应
            mainAxisSize: MainAxisSize.min,
            // 子组件垂直居中对齐
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 构建单选框
              _buildRadio(),
              // 单选框和文本之间的间距
              const SizedBox(width: 4.0),
              // 文本标签
              Text(
                widget.label,
                style: TextStyle(
                  // 文字颜色
                  color: const Color(0xD9000000),
                  // 字体大小
                  fontSize: 14,
                  // 行高
                  height: 16 / 14,
                  // 字体粗细：选中时加粗，否则正常
                  fontWeight: widget.value
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建单选框
  ///
  /// 根据选中状态显示不同的单选框样式：
  /// - 未选中：空圆框
  /// - 选中：圆框内有一个黑色圆点
  Widget _buildRadio() {
    return AnimatedContainer(
      // 动画时长 150ms
      duration: const Duration(milliseconds: 150),
      // 单选框的固定宽度和高度
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        // 背景颜色透明
        color: Colors.transparent,
        // 边框样式
        border: Border.all(color: _getBorderColor(), width: 1.5),
        // 圆形形状
        shape: BoxShape.circle,
      ),
      // 如果选中，显示内部圆点
      child: widget.value
          ? Center(
              child: Container(
                // 内部圆点的宽度和高度
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  // 内部圆点的颜色
                  color: Color(0xFF000000),
                  // 圆形形状
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  /// 根据状态获取边框颜色
  ///
  /// 颜色优先级：
  /// 1. 选中状态：黑色 (0xFF000000)
  /// 2. 悬停状态：黑色 (0xFF000000)
  /// 3. 默认状态：浅灰色 (0x61000000)
  Color _getBorderColor() {
    // 如果选中，返回黑色
    if (widget.value) return const Color(0xFF000000);
    // 如果悬停，返回黑色
    if (_isHovering) return const Color(0xFF000000);
    // 默认状态，返回浅灰色
    return const Color(0x61000000);
  }
}
