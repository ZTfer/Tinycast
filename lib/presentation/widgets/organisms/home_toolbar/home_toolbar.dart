import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/presentation/widgets/organisms/home_toolbar/home_toolbar_button.dart';
import 'package:tinycast/presentation/widgets/organisms/home_toolbar/sleep_dropdown.dart';
import 'package:tinycast/presentation/features/search/search_page.dart';

/// 主页工具栏
///
/// 位于主页底部的工具栏，提供主要功能的快速访问入口。
/// 包含添加任务、闹钟、以及侧边栏设置等功能按钮。
class HomeToolbar extends StatefulWidget {
  const HomeToolbar({super.key});

  @override
  State<HomeToolbar> createState() => _HomeToolbarState();
}

class _HomeToolbarState extends State<HomeToolbar> {
  final GlobalKey _sleepButtonKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown() {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox renderBox =
        _sleepButtonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 120.0;
    const double estimatedMenuHeight = 280.0;

    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: SleepDropdown(onItemSelected: _hideDropdown),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    _currentDropdownOverlay = _dropdownOverlay;
  }

  void _showSearchPage() {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox? renderBox =
        _searchButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 300.0;
    const double estimatedMenuHeight = 400.0;

    double left = (screenSize.width - estimatedMenuWidth) / 2;
    double top = offset.dy + size.height + 4;

    if (left < 8) {
      left = 8;
    }

    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: _SearchPageWrapper(onClose: _hideDropdown),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    _currentDropdownOverlay = _dropdownOverlay;
  }

  void _hideDropdown() {
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  void dispose() {
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return Container(
      color: theme.homeToolbarBackground,
      padding: theme.homeToolbarPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          HomeToolbarButton(
            icon: const Icon(LucideIcons.search, size: 16),

            onPressed: _showSearchPage,
            key: _searchButtonKey,
          ),

          const SizedBox(width: 8),
          HomeToolbarButton(
            icon: const Icon(
              LucideIcons.alarmClock,
              size: 16,
            ),
            onPressed: _showDropdown,
            key: _sleepButtonKey,
          ),
        ],
      ),
    );
  }
}

/// 搜索页面包装器，用于处理 ESC 键关闭
class _SearchPageWrapper extends StatefulWidget {
  final VoidCallback onClose;

  const _SearchPageWrapper({required this.onClose});

  @override
  State<_SearchPageWrapper> createState() => _SearchPageWrapperState();
}

class _SearchPageWrapperState extends State<_SearchPageWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: SearchPage(onClose: widget.onClose),
      ),
    );
  }
}
