import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 搜索输入框组件
///
/// 用于搜索播客的输入框组件，包含搜索图标、文字输入区域和清除按钮。
/// 采用 Material Design 风格，无边框圆角设计。
class SearchInput extends StatefulWidget {
  /// 创建搜索输入框组件
  const SearchInput({super.key});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  /// 文本编辑控制器，用于管理输入框的文本内容
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    /// 释放文本控制器资源，防止内存泄漏
    _controller.dispose();
    super.dispose();
  }

  /// 清空输入框内容
  ///
  /// 清除文本控制器中的内容，并触发界面刷新以隐藏清除按钮
  void _clearInput() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      /// 透明背景，让父组件的背景色显示出来
      color: Colors.transparent,
      child: Localizations(
        /// 设置本地化区域为英语（美国）
        locale: const Locale('en', 'US'),
        /// 提供 Material 和 Widgets 的本地化代理
        /// 这是使用 Material 组件（如 TextField）所必需的
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: TextField(
          /// 绑定文本控制器，用于控制和管理输入内容
          controller: _controller,
          /// 文本内容变化时的回调
          /// 触发 setState 刷新界面，用于控制清除按钮的显示/隐藏
          onChanged: (value) {
            setState(() {});
          },
          /// 输入框装饰配置
          decoration: InputDecoration(
            /// 左侧搜索图标
            /// 使用 Lucide 图标库的 search 图标
            prefixIcon: Icon(
              LucideIcons.search,
              size: 16.0,
              color: const Color(0xFF999999),
            ),
            // 调整前缀图标约束，减少右侧间距
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32.0,  // 默认是 48，减小这个值
              minHeight: 32.0,
            ),
            /// 右侧清除按钮
            /// 仅在输入框有内容时显示，点击后清空输入内容
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: _clearInput,
                    child: Icon(
                      LucideIcons.x,
                      size: 16.0,
                      color: const Color(0xFF333333),
                    ),
                  )
                : null,
                suffixIconConstraints: const BoxConstraints(
    minWidth: 32.0,  // 默认是 48，减小这个值
    minHeight: 32.0,
  ),
            /// 占位提示文字
            hintText: '搜索播客',
            /// 占位文字样式
            hintStyle: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF999999),
              height: 16.0 / 12.0,

            ),
            
            /// 启用背景填充
            filled: true,
            /// 背景填充颜色，浅灰色
            fillColor: const Color(0xFFF0F0F0),
            /// 默认边框样式
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            /// 聚焦状态下的边框样式
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            /// 启用状态下的边框样式
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            /// 内容区域内边距
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8.0,
            ),
            /// 输入框尺寸约束
            constraints: const BoxConstraints(
              minHeight: 34.0,
              maxHeight: 34.0,
            ),
          ),
          /// 输入文本样式
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xFF000000),
            height: 16.0 / 12.0,
          ),
          /// 光标颜色
          cursorColor: const Color(0xFF000000),
          /// 最大行数，限制为单行输入
          maxLines: 1,
          /// 最小行数，确保始终是单行
          minLines: 1,
        ),
      ),
    );
  }
}
