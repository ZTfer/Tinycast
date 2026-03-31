import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/features/library/library_list_item/library_show_more_button.dart';
import 'package:tinycast/presentation/features/library/library_show_dropdown/library_show_dropdown.dart';

/// Library 节目信息组件
///
/// 用于显示节目名称、更新时间和更多选项按钮。
/// 点击更多选项按钮会显示下拉菜单。
class LibraryShowInfo extends StatefulWidget {
  /// 节目名称
  final String showName;

  /// 更新时间（如 "1 h ago"）
  final String timeAgo;

  /// 更多按钮的回调
  final VoidCallback? onMorePressed;

  /// 标题点击回调
  final VoidCallback? onTitleTap;

  const LibraryShowInfo({
    super.key,
    required this.showName,
    required this.timeAgo,
    this.onMorePressed,
    this.onTitleTap,
  });

  @override
  State<LibraryShowInfo> createState() => _LibraryShowInfoState();
}

/// [LibraryShowInfo] 的状态类
///
/// 管理下拉菜单的显示和隐藏状态。
class _LibraryShowInfoState extends State<LibraryShowInfo> {
  /// 更多按钮的 GlobalKey，用于获取按钮的位置和大小
  final GlobalKey _moreButtonKey = GlobalKey();

  /// 下拉菜单的 OverlayEntry，用于控制菜单的显示和移除
  OverlayEntry? _dropdownOverlay;

  /// 标题 hover 状态
  bool _isHovered = false;

  /// 全局当前显示的下拉菜单，用于确保同一时间只显示一个菜单
  static OverlayEntry? _currentDropdownOverlay;

  /// 显示下拉菜单
  ///
  /// 获取更多按钮的位置和大小，在按钮下方显示下拉菜单。
  /// 菜单位置：按钮下方 4px 处。
  /// 自动调整位置，避免菜单超出屏幕边界。
  /// 如果已有下拉菜单显示，先关闭它。
  void _showDropdown() {
    /// 如果已有下拉菜单显示，先关闭它（包括当前按钮的菜单）
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    /// 获取更多按钮的 RenderBox
    final RenderBox renderBox =
        _moreButtonKey.currentContext?.findRenderObject() as RenderBox;

    /// 获取按钮在全局坐标系中的偏移量
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    /// 获取按钮的尺寸
    final Size size = renderBox.size;

    /// 获取屏幕尺寸
    final Size screenSize = MediaQuery.of(context).size;

    /// 计算菜单的预估宽度（用于边界检测）
    const double estimatedMenuWidth = 120.0;
    const double estimatedMenuHeight = 180.0;

    /// 计算菜单位置
    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    /// 如果菜单超出右边界，向左调整
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    /// 如果菜单超出下边界，向上显示
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    /// 创建下拉菜单的 OverlayEntry
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          /// 覆盖整个屏幕的透明层，用于捕获点击空白处
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),

          /// 下拉菜单，定位在按钮下方
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              /// 阻止事件冒泡，点击菜单内部不关闭
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: LibraryShowDropdown(
                /// 菜单项选中时关闭下拉菜单
                onItemSelected: _hideDropdown,
              ),
            ),
          ),
        ],
      ),
    );

    /// 将 OverlayEntry 插入到 Overlay 中
    Overlay.of(context).insert(_dropdownOverlay!);

    /// 更新全局当前显示的下拉菜单
    _currentDropdownOverlay = _dropdownOverlay;
  }

  /// 隐藏下拉菜单
  ///
  /// 移除 OverlayEntry 并清空引用。
  void _hideDropdown() {
    /// 如果隐藏的是当前全局菜单，清空全局引用
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  /// 组件销毁时的清理工作
  ///
  /// 移除下拉菜单的 OverlayEntry，防止内存泄漏。
  @override
  void dispose() {
    /// 如果销毁的是当前全局菜单，清空全局引用
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: widget.onTitleTap,
                child: Text(
                  widget.showName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000),
                    decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ),
            ),
            LibraryShowMoreButton(
              /// 绑定 GlobalKey，用于获取位置
              key: _moreButtonKey,

              /// 更多图标
              icon: const Icon(LucideIcons.ellipsisVertical),

              /// 点击时显示下拉菜单
              onPressed: widget.onMorePressed ?? _showDropdown,
            ),
          ],
        ),
        Text(
          widget.timeAgo,
          style: const TextStyle(fontSize: 10, color: Color(0xD9000000)),
        ),
      ],
    );
  }
}
