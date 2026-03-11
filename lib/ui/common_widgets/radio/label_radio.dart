import 'package:flutter/material.dart';

/// 单选框组件
///
/// 用于显示可点击的单选框和文本标签，支持选中/未选中状态切换。
/// 包含悬停和选中状态的视觉反馈。
class LabelRadio extends StatefulWidget {
  /// 单选框是否被选中
  final bool value;

  /// 单选框显示的文本标签
  final String label;

  /// 单选框状态改变时的回调函数
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
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onChanged(true),
        child: AnimatedContainer(
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRadio(),
              const SizedBox(width: 4.0),
              Text(
                widget.label,
                style: TextStyle(
                  color: const Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
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
  Widget _buildRadio() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: _getBorderColor(), width: 1.5),
        shape: BoxShape.circle,
      ),
      child: widget.value
          ? Center(
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF000000),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  /// 根据状态获取边框颜色
  Color _getBorderColor() {
    if (widget.value) return const Color(0xFF000000);
    if (_isHovering) return const Color(0xFF000000);
    return const Color(0x61000000);
  }
}
