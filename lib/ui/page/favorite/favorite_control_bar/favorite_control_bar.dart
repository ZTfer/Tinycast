import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/favorite/favorite_control_bar/favorite_more_button.dart';
import 'package:tinycast/ui/page/favorite/favorite_control_bar/favorite_action_button.dart';
import 'package:tinycast/ui/page/favorite/favorite_episode_dropdown/favorite_episode_dropdown.dart';

/// Favorite 控制栏组件
///
/// 用于收藏列表项中的操作区域。
/// 包含播放按钮、收藏按钮和更多选项图标。
/// 点击更多选项图标会显示下拉菜单。
class FavoriteControlBar extends StatefulWidget {
  const FavoriteControlBar({super.key});

  @override
  State<FavoriteControlBar> createState() => _FavoriteControlBarState();
}

/// [FavoriteControlBar] 的状态类
///
/// 管理下拉菜单的显示和隐藏状态。
class _FavoriteControlBarState extends State<FavoriteControlBar> {
  /// 更多按钮的 GlobalKey，用于获取按钮的位置和大小
  final GlobalKey _moreButtonKey = GlobalKey();

  /// 下拉菜单的 OverlayEntry，用于控制菜单的显示和移除
  OverlayEntry? _dropdownOverlay;

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
    const double estimatedMenuWidth = 140.0;
    const double estimatedMenuHeight = 280.0;

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
              child: FavoriteEpisodeDropdown(
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListPlayButton(
          icon: const Icon(LucideIcons.play),
          label: 'Play',
          onPressed: () {},
          iconSize: 10,
          fontSize: 10,
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
        ),
        const Spacer(),
        FavoriteActionButton(
          icon: const Icon(LucideIcons.star),
          onPressed: () {},
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
        const SizedBox(width: 2),
        FavoriteMoreButton(
          /// 绑定 GlobalKey，用于获取位置
          key: _moreButtonKey,

          /// 更多图标
          icon: const Icon(LucideIcons.ellipsisVertical),

          /// 点击时显示下拉菜单
          onPressed: _showDropdown,

          /// 图标大小 12
          iconSize: 12,

          /// 内容颜色（85% 不透明度的黑色）
          contentColor: const Color(0xD9000000),
        ),
      ],
    );
  }
}
