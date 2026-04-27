import 'package:flutter/material.dart';
import 'package:tinycast/presentation/features/settings/play_settings/skip_time_settings/skip_time_dropdown.dart';
import 'package:tinycast/presentation/features/settings/widgets/settings_dropdown_button.dart';

/// 快进/快退时间设置组件
///
/// 提供播放控制中快进和快退时间的选择功能。
/// 使用 Overlay 实现下拉菜单，支持边界检测和全局单例管理。
class SkipTimeSettings extends StatefulWidget {
  const SkipTimeSettings({super.key});

  @override
  State<SkipTimeSettings> createState() => _SkipTimeSettingsState();
}

class _SkipTimeSettingsState extends State<SkipTimeSettings> {
  /// 快进按钮的 GlobalKey，用于获取按钮在屏幕上的位置
  final GlobalKey _forwardButtonKey = GlobalKey();

  /// 快退按钮的 GlobalKey，用于获取按钮在屏幕上的位置
  final GlobalKey _rewindButtonKey = GlobalKey();

  /// 当前实例的下拉菜单 Overlay 入口
  OverlayEntry? _dropdownOverlay;

  /// 静态变量：全局唯一当前显示的下拉菜单
  /// 用于确保同一时间只有一个下拉菜单显示，避免多个菜单重叠
  static OverlayEntry? _currentDropdownOverlay;

  /// 显示下拉菜单
  ///
  /// [buttonKey] 触发菜单的按钮的 GlobalKey
  ///
  /// 执行流程：
  /// 1. 关闭当前已打开的菜单（全局单例管理）
  /// 2. 获取按钮在屏幕上的绝对位置和尺寸
  /// 3. 计算菜单位置，处理右边界和下边界溢出
  /// 4. 创建 OverlayEntry 并插入 Overlay
  void _showDropdown(GlobalKey buttonKey) {
    // 关闭当前已打开的菜单，避免多个菜单同时显示
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    // 获取按钮的 RenderBox，用于计算位置
    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;

    // 将按钮的本地坐标转换为屏幕绝对坐标
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // 获取屏幕尺寸，用于边界检测
    final Size screenSize = MediaQuery.of(context).size;

    // 预估菜单的宽度和高度，用于边界计算
    const double estimatedMenuWidth = 150.0;
    const double estimatedMenuHeight = 160.0;

    // 计算菜单初始位置：按钮正下方，间隔 4 像素
    double left = offset.dx;
    double top = offset.dy + size.height - 10;

    // 右边界检测：如果菜单超出屏幕右边缘，则向左对齐
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    // 下边界检测：如果菜单超出屏幕底部，则显示在按钮上方
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 20;
    }

    // 创建下拉菜单的 OverlayEntry
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏透明遮罩层，点击空白处关闭菜单
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 下拉菜单内容
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              // 阻止事件穿透到遮罩层
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: SkipTimeDropdown(onItemSelected: _hideDropdown),
            ),
          ),
        ],
      ),
    );

    // 将菜单插入到 Overlay 中显示
    Overlay.of(context).insert(_dropdownOverlay!);

    // 记录当前显示的菜单，用于全局单例管理
    _currentDropdownOverlay = _dropdownOverlay;
  }

  /// 隐藏下拉菜单
  ///
  /// 清理当前实例的菜单引用，并清除全局菜单引用（如果是当前实例的菜单）
  void _hideDropdown() {
    // 如果当前显示的是本实例的菜单，清除全局引用
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    // 移除菜单并清理引用
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  /// 组件销毁时清理资源
  @override
  void dispose() {
    // 如果当前显示的是本实例的菜单，清除全局引用
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    // 移除菜单
    _dropdownOverlay?.remove();
    super.dispose();
  }

  /// 构建组件布局
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 快进时间设置行
        Row(
          spacing: 8,
          children: [
            SettingsDropdownButton(
              key: _forwardButtonKey,
              label: '30 秒',
              onPressed: () => _showDropdown(_forwardButtonKey),
            ),
            const Text(
              '快进',
              style: TextStyle(
                color: Color(0xD9000000),
                fontSize: 14,
                height: 16 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 快退时间设置行
        Row(
          spacing: 8,
          children: [
            SettingsDropdownButton(
              key: _rewindButtonKey,
              label: '15 秒',
              onPressed: () => _showDropdown(_rewindButtonKey),
            ),
            const Text(
              '快退',
              style: TextStyle(
                color: Color(0xD9000000),
                fontSize: 14,
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
