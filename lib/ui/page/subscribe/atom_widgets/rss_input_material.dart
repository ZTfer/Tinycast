import 'package:flutter/material.dart';

/// RSS输入框组件（Material Design）
///
/// 使用 Material Design 的 TextField 实现的RSS订阅链接输入框。
/// 包含占位文字提示，支持用户输入和焦点状态。
/// 
// TODO： 1. 修改 hover 样式，颜色再淡一点，添加一个缓动动画
// TODO： 2. 输入的内容为 ip、网址

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
      decoration: InputDecoration(
        /// 让输入框更紧凑
        // isDense: true,

        /// 占位文字内容
        hintText: 'https://domain.com/podcast.rss',

        /// 占位文字样式
        hintStyle: const TextStyle(
          /// 字体大小：12px
          fontSize: 12.0,

          /// 文字颜色：黑色30%透明度
          color: Color(0x4D000000),

          /// 行高：16px
          height: 16.0 / 12.0,
        ),

        /// 填充背景色
        filled: true,
        fillColor: const Color(0xFFF0F0F0),

        /// 圆角边框
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),

        /// 禁用状态的边框
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),

        /// 聚焦状态的边框
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),

        /// 内边距
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),

        /// 最小高度约束
        constraints: const BoxConstraints(minHeight: 34.0, maxHeight: 40.0),

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
