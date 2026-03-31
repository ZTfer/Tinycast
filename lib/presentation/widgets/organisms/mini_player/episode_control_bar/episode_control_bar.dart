import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/episode_control_bar/episode_control_button.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/episode_control_bar/play_pause_button.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/speed_dropdown/speed_dropdown.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/volume_control_bar/volume_control_popup.dart';

/// 剧集控制栏
///
/// 位于播放器底部的控制栏，提供播放速度、播放控制（后退、播放/暂停、前进）和音量控制功能。
/// 使用 Overlay 实现下拉菜单和弹出窗口，支持点击遮罩层关闭弹出窗口。
class EpisodeControlBar extends ConsumerStatefulWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;

  const EpisodeControlBar({
    super.key,
    this.isPlaying = false,
    required this.onPlayPause,
    required this.onSeekForward,
    required this.onSeekBackward,
  });

  @override
  ConsumerState<EpisodeControlBar> createState() => _EpisodeControlBarState();
}

class _EpisodeControlBarState extends ConsumerState<EpisodeControlBar> {
  /// 播放速度按钮的 GlobalKey，用于获取按钮的位置信息
  final GlobalKey _speedButtonKey = GlobalKey();

  /// 音量控制按钮的 GlobalKey，用于获取按钮的位置信息
  final GlobalKey _volumeButtonKey = GlobalKey();

  /// 当前显示的弹出窗口的 OverlayEntry
  OverlayEntry? _dropdownOverlay;

  /// 静态变量，用于跟踪当前显示的弹出窗口
  /// 确保同一时间只显示一个弹出窗口
  static OverlayEntry? _currentDropdownOverlay;

  /// 显示播放速度下拉菜单
  ///
  /// 1. 如果已有弹出窗口，先关闭它
  /// 2. 获取播放速度按钮的位置和大小
  /// 3. 计算下拉菜单的显示位置（在按钮下方）
  /// 4. 处理边界情况，防止菜单超出屏幕
  /// 5. 创建 Overlay 并插入到 Overlay 层
  void _showDropdown() {
    // 如果已有弹出窗口，先关闭它
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    // 获取播放速度按钮的 RenderBox，用于计算位置
    final RenderBox renderBox =
        _speedButtonKey.currentContext?.findRenderObject() as RenderBox;

    // 将按钮的本地坐标转换为全局坐标
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    // 估计的菜单尺寸
    const double estimatedMenuWidth = 110.0;
    const double estimatedMenuHeight = 200.0;

    // 计算菜单的初始位置（在按钮下方）
    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    // 如果菜单右侧超出屏幕，向左调整
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    // 如果菜单底部超出屏幕，向上调整
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    // 获取当前播放速度
    final currentSpeed = ref.read(speedProvider);

    // 创建弹出窗口的 OverlayEntry
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏遮罩层，点击时关闭弹出窗口
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 播放速度下拉菜单
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: SpeedDropdown(
                currentSpeed: currentSpeed,
                onSpeedChanged: (speed) {
                  ref.read(playbackProvider.notifier).setSpeed(speed);
                },
                onItemSelected: _hideDropdown,
              ),
            ),
          ),
        ],
      ),
    );

    // 将弹出窗口插入到 Overlay 层
    Overlay.of(context).insert(_dropdownOverlay!);
    _currentDropdownOverlay = _dropdownOverlay;
  }

  /// 显示音量控制弹出窗口
  ///
  /// 1. 如果已有弹出窗口，先关闭它
  /// 2. 获取音量按钮的位置和大小
  /// 3. 计算音量控制条的显示位置（在按钮下方）
  /// 4. 处理边界情况，防止控制条超出屏幕
  /// 5. 创建 Overlay 并插入到 Overlay 层
  void _showVolumeControl() {
    // 如果已有弹出窗口，先关闭它
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    // 获取音量按钮的 RenderBox，用于计算位置
    final RenderBox? renderBox =
        _volumeButtonKey.currentContext?.findRenderObject() as RenderBox?;

    // 如果无法获取 RenderBox，直接返回
    if (renderBox == null) {
      return;
    }

    // 将按钮的本地坐标转换为全局坐标
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    // 估计的音量控制条尺寸
    const double estimatedMenuWidth = 140.0;
    const double estimatedMenuHeight = 60.0;

    // 计算控制条的初始位置（在按钮下方）
    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    // 如果控制条右侧超出屏幕，向左调整
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    // 如果控制条底部超出屏幕，向上调整
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    // 创建弹出窗口的 OverlayEntry
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏遮罩层，点击时关闭弹出窗口
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 音量控制条
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const VolumeControlPopup(),
            ),
          ),
        ],
      ),
    );

    // 将弹出窗口插入到 Overlay 层
    Overlay.of(context).insert(_dropdownOverlay!);
    _currentDropdownOverlay = _dropdownOverlay;
  }

  /// 隐藏弹出窗口
  ///
  /// 1. 如果当前弹出窗口是全局跟踪的窗口，清除全局跟踪
  /// 2. 移除并清空弹出窗口
  void _hideDropdown() {
    // 如果当前弹出窗口是全局跟踪的窗口，清除全局跟踪
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    // 移除并清空弹出窗口
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  void dispose() {
    // 组件销毁时，如果当前弹出窗口是全局跟踪的窗口，清除全局跟踪
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    // 移除弹出窗口，防止内存泄漏
    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前播放速度
    final currentSpeed = ref.watch(speedProvider);

    return Container(
      // 控制栏的垂直和水平内边距
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        // 子组件两端对齐，播放速度在左，音量在右
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 播放速度控制按钮
          EpisodeControlButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.gauge400,
                  size: 16,
                  fontWeight: FontWeight.normal,
                ),
                const SizedBox(width: 4),
                Text(
                  '${currentSpeed}x',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            onPressed: _showDropdown,
            key: _speedButtonKey,
          ),
          Row(
            // 播放控制按钮之间的间距
            spacing: 40,
            children: [
              // 后退30秒按钮
              EpisodeControlButton(
                icon: const Icon(
                  LucideIcons.undoDot,
                  size: 20,
                  fontWeight: FontWeight.normal,
                ),
                onPressed: widget.onSeekBackward,
              ),
              // 播放/暂停按钮
              PlayPauseButton(onPressed: widget.onPlayPause),
              // 前进30秒按钮
              EpisodeControlButton(
                icon: const Icon(
                  LucideIcons.redoDot400,
                  size: 20,
                  fontWeight: FontWeight.normal,
                ),
                onPressed: widget.onSeekForward,
              ),
            ],
          ),
          // 音量控制按钮
          EpisodeControlButton(
            icon: const Icon(
              LucideIcons.volume2,
              size: 16,
              fontWeight: FontWeight.normal,
            ),
            onPressed: _showVolumeControl,
            key: _volumeButtonKey,
          ),
        ],
      ),
    );
  }
}
