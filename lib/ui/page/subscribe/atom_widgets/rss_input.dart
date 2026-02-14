import 'package:flutter/material.dart';

/// RSS输入框组件
///
/// 用于输入RSS订阅链接的文本输入框。
/// 包含占位文字提示，支持用户输入和焦点状态。
class RssInput extends StatefulWidget {
  /// 输入框的初始值
  final String initialValue;

  /// 输入内容变化的回调函数
  final ValueChanged<String>? onChanged;

  /// 输入框完成编辑的回调函数
  final ValueChanged<String>? onSubmitted;

  /// 输入框是否可用
  final bool enabled;

  const RssInput({
    super.key,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<RssInput> createState() => _RssInputState();
}

class _RssInputState extends State<RssInput> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8.0),
          border: _isFocused
              ? Border.all(color: const Color(0xFF000000), width: 1.0)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
        child: TextField(
          controller: _controller,
          enabled: widget.enabled,
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xFF000000),
            height: 16.0 / 12.0,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: 'https://domain.com/podcast.rss',
            hintStyle: const TextStyle(
              fontSize: 12.0,
              color: Color(0x4D000000),
              height: 16.0 / 12.0,
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
