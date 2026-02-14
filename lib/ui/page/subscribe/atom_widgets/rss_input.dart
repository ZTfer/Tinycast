import 'package:flutter/widgets.dart';

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
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _isEmpty => _controller.text.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: GestureDetector(
        onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8.0),
            border: _isFocused
                ? Border.all(color: const Color(0xFF000000), width: 1.0)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
          child: Stack(
            children: [
              if (_isEmpty)
                Positioned.fill(
                  child: Text(
                    'https://domain.com/podcast.rss',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0x4D000000),
                      height: 16.0 / 12.0,
                    ),
                  ),
                ),
              EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF000000),
                  height: 16.0 / 12.0,
                ),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
                selectionColor: const Color(0x40000000),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
