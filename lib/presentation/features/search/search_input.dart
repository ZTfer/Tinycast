import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'search_provider.dart';
import '../../../core/router/app_router.dart';

/// 搜索输入框组件
///
/// 用于搜索播客的输入框组件，包含搜索图标、文字输入区域和清除按钮。
/// 采用 Material Design 风格，无边框圆角设计。
/// 支持键盘导航（上下箭头选择，Enter 确认或搜索）。
class SearchInput extends ConsumerStatefulWidget {
  /// 创建搜索输入框组件
  const SearchInput({super.key});

  @override
  ConsumerState<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends ConsumerState<SearchInput> {
  /// 文本编辑控制器，用于管理输入框的文本内容
  final TextEditingController _controller = TextEditingController();

  /// 焦点节点，用于处理键盘事件
  final FocusNode _focusNode = FocusNode();

  /// 用于追踪上次同步的搜索关键词，避免循环更新
  String _lastSyncedKeyword = '';

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        ref.read(searchProvider.notifier).selectNext();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        ref.read(searchProvider.notifier).selectPrevious();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        final keyword = _controller.text.trim();
        if (keyword.isNotEmpty) {
          ref.read(searchProvider.notifier).search(keyword);
        } else {
          final target = ref.read(searchProvider.notifier).confirmSelection();
          if (target != null) {
            AppRouter.navigateTo(
              context,
              target.route,
              arguments: target.arguments,
            );
          }
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// 清空输入框内容
  void _clearInput() {
    _controller.clear();
    _lastSyncedKeyword = '';
    ref.read(searchProvider.notifier).resetToHistory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchKeyword = ref.watch(searchProvider).searchKeyword;

    // 只有当 provider 中的关键词发生变化时才同步到 controller
    // 这避免了在用户编辑时（如按 Backspace）强制覆盖用户输入
    if (searchKeyword != _lastSyncedKeyword) {
      _lastSyncedKeyword = searchKeyword;
      if (_controller.text != searchKeyword) {
        _controller.text = searchKeyword;
        _controller.selection = TextSelection.collapsed(
          offset: searchKeyword.length,
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
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
            hintText: '搜索播客',
            hintStyle: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF999999),
              height: 16.0 / 12.0,
            ),
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            constraints: const BoxConstraints(
              minHeight: 34.0,
              maxHeight: 34.0,
            ),
          ),
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xFF000000),
            height: 16.0 / 12.0,
          ),
          cursorColor: const Color(0xFF000000),
          maxLines: 1,
          minLines: 1,
        ),
      ),
    );
  }
}
