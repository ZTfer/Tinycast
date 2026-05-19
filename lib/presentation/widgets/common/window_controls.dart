import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Windows 自定义窗口标题栏
///
/// 包含窗口拖拽区域、标题和最小化/最大化/关闭按钮
/// 仅在 Windows 平台显示，其他平台返回空 Widget
class WindowControls extends StatelessWidget {
  final Widget? leading;
  final String? title;

  const WindowControls({super.key, this.leading, this.title});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 40,
        color: const Color(0xFFF0F0F0),
        child: Row(
          children: [
            if (leading != null)
              Padding(padding: const EdgeInsets.only(left: 12), child: leading!)
            else if (title != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              const SizedBox(width: 12),
            const Spacer(),
            _WindowButton(
              icon: Icons.remove,
              onPressed: windowManager.minimize,
            ),
            _WindowButton(
              icon: Icons.crop_square,
              size: 18,
              onPressed: windowManager.maximize,
            ),
            _WindowButton(
              icon: Icons.close,
              size: 18,
              isClose: true,
              onPressed: windowManager.close,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.size = 16,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 32,
          alignment: Alignment.center,
          color: _isHovered
              ? (widget.isClose ? const Color(0xFFE81123) : const Color(0x1A000000))
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _isHovered
                ? (widget.isClose ? Colors.white : const Color(0xFF000000))
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
