import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/home_toolbar_button.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/sleep_dropdown/sleep_dropdown.dart';
import 'package:tinycast/ui/page/search/search_page.dart';

/// 主页工具栏
///
/// 位于主页底部的工具栏，提供主要功能的快速访问入口。
/// 包含添加任务、番茄钟/闹钟、以及侧边栏设置等功能按钮。
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

    final RenderBox renderBox =
        _searchButtonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 300.0;
    const double estimatedMenuHeight = 400.0;

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
              child: Center(child: SearchPage()),
            ),
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
    // 使用 Container 设置背景色和内边距，确保工具栏在视觉上与周围内容区分开
    return Container(
      // color: const Color(0xFFFFFFFF), // 白色背景
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 宽度自适应内容，保持紧凑
        children: [
          Spacer(), // 占据左侧所有空间
          // 添加按钮
          // 用于快速创建新的任务或项目
          HomeToolbarButton(
            icon: const Icon(LucideIcons.search, size: 16),
            onPressed: _showSearchPage,
            key: _searchButtonKey,
          ),
          const SizedBox(width: 8), // 按钮之间的间距
          // 闹钟/专注按钮
          // 用于进入定时器功能
          HomeToolbarButton(
            icon: const Icon(
              LucideIcons.alarmClock,
              size: 16,
            ), // 使用 Lucide 图标库的闹钟图标
            // label: '闹钟', // 暂时隐藏标签
            onPressed: _showDropdown,
            key: _sleepButtonKey,
          ),
          const SizedBox(width: 8),

          /*
          // 侧边栏按钮
          // 用于展开收起窗口，让窗口变成紧凑模式或者展开
          // 暂时不开发这个功能，先注释掉
          HomeToolbarButton(
            icon: const Icon(
              LucideIcons.panelLeftOpen,
              size: 16,
            ), // 使用 Lucide 图标库的侧边栏图标
            // label: 'Settings', // 暂时隐藏标签
            onPressed: () {
              debugPrint('Settings pressed');
            },
          ),
          */
        ],
      ),
    );
  }
}
