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
  /// 文本编辑控制器，用于管理输入框的文本内容
  late TextEditingController _controller;

  /// 焦点节点，用于管理输入框的焦点状态
  late FocusNode _focusNode;

  /// 记录输入框是否获得焦点
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    /// 初始化文本控制器，设置初始值
    _controller = TextEditingController(text: widget.initialValue);

    /// 初始化焦点节点
    _focusNode = FocusNode();

    /// 添加文本变化监听器，用于更新UI状态
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    /// 移除文本变化监听器
    _controller.removeListener(_onTextChanged);

    /// 释放文本控制器资源
    _controller.dispose();

    /// 释放焦点节点资源
    _focusNode.dispose();
    super.dispose();
  }

  /// 文本内容变化时的回调函数
  ///
  /// 当用户在输入框中输入或删除文字时触发，
  /// 用于更新UI状态（如显示/隐藏占位文字）。
  void _onTextChanged() {
    setState(() {});
  }

  /// 判断输入框是否为空
  ///
  /// 用于决定是否显示占位文字。
  bool get _isEmpty => _controller.text.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Focus(
      /// 绑定焦点节点
      focusNode: _focusNode,

      /// 焦点状态变化时的回调
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: GestureDetector(
        /// 点击输入框区域时请求焦点
        onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
        child: Container(
          /// 容器装饰样式
          decoration: BoxDecoration(
            /// 背景色：浅灰色
            color: const Color(0xFFF0F0F0),

            /// 圆角：8px
            borderRadius: BorderRadius.circular(8.0),

            /// 边框：获得焦点时显示黑色边框（内边框）
            border: _isFocused
                ? Border.all(color: const Color(0xFF000000), width: 1.0)
                : null,
          ),

          /// 内边距：水平12px，垂直9px（边框占据的空间从padding中扣除）
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: _isFocused ? 8.0 : 9.0,
          ),

          /// 根据输入框是否为空显示不同内容
          child: _isEmpty
              /// 输入框为空时显示占位文字
              ? SizedBox(
                  /// 填充父容器的宽度
                  width: double.infinity,
                  child: Text(
                    'https://domain.com/podcast.rss',
                    style: const TextStyle(
                      /// 字体大小：12px
                      fontSize: 12.0,

                      /// 文字颜色：黑色30%透明度
                      color: Color(0x4D000000),

                      /// 行高：16px（用于垂直居中对齐）
                      height: 16.0 / 12.0,
                    ),
                  ),
                )
              /// 输入框不为空时显示可编辑文本框
              : SizedBox(
                  /// 填充父容器的宽度
                  width: double.infinity,
                  child: EditableText(
                    /// 绑定文本控制器
                    controller: _controller,

                    /// 绑定焦点节点
                    focusNode: _focusNode,

                    /// 文本样式
                    style: const TextStyle(
                      /// 字体大小：12px
                      fontSize: 12.0,

                      /// 文字颜色：黑色
                      color: Color(0xFF000000),

                      /// 行高：16px
                      height: 16.0 / 12.0,
                    ),

                    /// 光标颜色：黑色
                    cursorColor: const Color(0xFF000000),

                    /// 光标背景色：黑色
                    backgroundCursorColor: const Color(0xFF000000),

                    /// 选中文字的背景色：黑色25%透明度
                    selectionColor: const Color(0x40000000),

                    /// 文本内容变化时的回调
                    onChanged: widget.onChanged,

                    /// 提交文本时的回调（如按回车键）
                    onSubmitted: widget.onSubmitted,

                    /// 最大行数：1（单行输入）
                    maxLines: 1,

                    /// 最小行数：1（确保始终是单行）
                    minLines: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
