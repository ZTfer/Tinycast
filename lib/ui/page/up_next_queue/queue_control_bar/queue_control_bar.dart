import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_control_bar/queue_more_button.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_episode_dropdown/queue_episode_dropdown.dart';

/// Queue 控制栏组件
///
/// 用于待播放队列列表项中的操作区域。
/// 包含播放按钮（带时长）和更多选项图标。
/// 点击更多选项图标会显示下拉菜单。
class QueueControlBar extends StatefulWidget {
  /// 节目时长（如 "32 min"）
  final String duration;

  const QueueControlBar({super.key, required this.duration});

  @override
  State<QueueControlBar> createState() => _QueueControlBarState();
}

/// [QueueControlBar] 的状态类
///
/// 管理下拉菜单的显示和隐藏状态。
class _QueueControlBarState extends State<QueueControlBar> {
  /// 更多按钮的 GlobalKey，用于获取按钮的位置和大小
  final GlobalKey _moreButtonKey = GlobalKey();

  /// 下拉菜单的 OverlayEntry，用于控制菜单的显示和移除
  OverlayEntry? _dropdownOverlay;

  /// 显示下拉菜单
  ///
  /// 获取更多按钮的位置和大小，在按钮下方显示下拉菜单。
  /// 菜单位置：按钮下方 4px 处。
  /// 自动调整位置，避免菜单超出屏幕边界。
  void _showDropdown() {
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
    const double estimatedMenuWidth = 150.0;
    const double estimatedMenuHeight = 230.0;

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
      builder: (context) => Positioned(
        /// 覆盖整个屏幕
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,

        /// 手势检测器，用于处理点击外部关闭菜单
        child: GestureDetector(
          /// 点击外部区域时关闭菜单
          onTap: _hideDropdown,

          /// 透明容器，覆盖整个屏幕
          child: Container(
            color: Colors.transparent,

            /// Stack 用于叠加下拉菜单
            child: Stack(
              children: [
                /// 下拉菜单，定位在按钮下方
                Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    /// 阻止事件冒泡，点击菜单内部不关闭
                    onTap: () {},
                    child: QueueEpisodeDropdown(
                      /// 菜单项选中时关闭下拉菜单
                      onItemSelected: _hideDropdown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /// 将 OverlayEntry 插入到 Overlay 中
    Overlay.of(context).insert(_dropdownOverlay!);
  }

  /// 隐藏下拉菜单
  ///
  /// 移除 OverlayEntry 并清空引用。
  void _hideDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  /// 组件销毁时的清理工作
  ///
  /// 移除下拉菜单的 OverlayEntry，防止内存泄漏。
  @override
  void dispose() {
    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      /// 主轴尺寸最小，根据内容自适应
      mainAxisSize: MainAxisSize.min,

      /// 子组件列表
      children: [
        /// 播放按钮（带时长）
        ListPlayButton(
          /// 播放图标
          icon: const Icon(LucideIcons.play),

          /// 节目时长标签
          label: widget.duration,

          /// 点击回调（暂无实现）
          onPressed: () {},

          /// 图标大小 10
          iconSize: 10,

          /// 字体大小 10
          fontSize: 10,

          /// 水平内边距 8
          horizontalPadding: 8,

          /// 垂直内边距 4
          verticalPadding: 4,

          /// 圆角半径 10
          borderRadius: 10,
        ),

        /// 占位符，将播放按钮和更多按钮分开
        const Spacer(),

        /// 更多选项按钮
        QueueMoreButton(
          /// 绑定 GlobalKey，用于获取位置
          key: _moreButtonKey,

          /// 更多图标
          icon: const Icon(LucideIcons.moreHorizontal),

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
