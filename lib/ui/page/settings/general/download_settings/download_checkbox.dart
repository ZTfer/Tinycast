// import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// 复选框组件
///
/// 用于显示可点击的复选框和文本标签，支持选中/未选中状态切换。
/// 包含悬停、按下和选中状态的视觉反馈。
class DownloadCheckbox extends StatefulWidget {
  /// 复选框是否被选中
  final bool value;

  /// 复选框显示的文本标签
  final String label;

  /// 复选框状态改变时的回调函数
  final ValueChanged<bool> onChanged;

  const DownloadCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<DownloadCheckbox> createState() => _DownloadCheckboxState();
}

class _DownloadCheckboxState extends State<DownloadCheckbox> {
  /// 鼠标是否悬停在复选框上
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
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
              _buildCheckbox(),
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

  /// 构建复选框
  Widget _buildCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: widget.value ? const Color(0xFF000000) : Colors.transparent,
        border: Border.all(
          color: _getBorderColor(),
          width: widget.value ? 0.0 : 1.5,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: widget.value
          ? const Icon(Icons.check, size: 14.0, color: Color(0xFFFFFFFF))
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
