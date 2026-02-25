import 'package:flutter/material.dart';

/// RSS输入框组件（Material Design）
///
/// 使用 Material Design 的 TextField 实现的RSS订阅链接输入框。
/// 包含占位文字提示，支持用户输入和焦点状态。
class RssInputMaterial extends StatefulWidget {
  /// 输入框的初始值
  final String initialValue;

  /// 输入内容变化的回调函数
  final ValueChanged<String>? onChanged;

  /// 输入框完成编辑的回调函数
  final ValueChanged<String>? onSubmitted;

  /// 输入框是否可用
  final bool enabled;

  const RssInputMaterial({
    super.key,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<RssInputMaterial> createState() => _RssInputMaterialState();
}

class _RssInputMaterialState extends State<RssInputMaterial> {
  /// 文本编辑控制器，用于管理输入框的文本内容
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    /// 初始化文本控制器，设置初始值
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    /// 释放文本控制器资源
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      /// 绑定文本控制器
      controller: _controller,

      /// 是否可用
      enabled: widget.enabled,

      /// 占位文字
      decoration: const InputDecoration(
        /// 占位文字内容
        hintText: 'https://domain.com/podcast.rss',

        /// 占位文字样式
        hintStyle: TextStyle(
          /// 字体大小：12px
          fontSize: 12.0,

          /// 文字颜色：黑色30%透明度
          color: Color(0x4D000000),

          /// 行高：16px
          height: 16.0 / 12.0,
        ),

        /// 去除默认的边框
        border: InputBorder.none,

        /// 去除默认的填充
        contentPadding: EdgeInsets.zero,

        /// 去除默认的标签
        label: null,
      ),

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

      /// 文本内容变化时的回调
      onChanged: widget.onChanged,

      /// 提交文本时的回调（如按回车键）
      onSubmitted: widget.onSubmitted,

      /// 最大行数：1（单行输入）
      maxLines: 1,

      /// 最小行数：1（确保始终是单行）
      minLines: 1,
    );
  }
}
