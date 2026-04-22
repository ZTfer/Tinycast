import 'package:flutter/material.dart';
import 'package:tinycast/presentation/features/settings/widgets/settings_dropdown_button.dart';
import 'package:tinycast/presentation/features/settings/general_settings/auto_download_settings/auto_download_settings_dropdown.dart';

class AutoDownloadSettings extends StatefulWidget {
  const AutoDownloadSettings({super.key});

  @override
  State<AutoDownloadSettings> createState() => _AutoDownloadSettingsState();
}

class _AutoDownloadSettingsState extends State<AutoDownloadSettings> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown() {
    // 关闭其他已打开的下拉菜单（全局单例，确保同时只有一个菜单打开）
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    // 获取按钮的渲染对象和位置信息
    final RenderBox renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox;
    // 按钮左上角相对于屏幕的偏移量
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    // 按钮的尺寸
    final Size size = renderBox.size;
    // 屏幕尺寸
    final Size screenSize = MediaQuery.of(context).size;

    // 预估菜单的宽高（用于边界检测）
    const double estimatedMenuWidth = 200.0;
    const double estimatedMenuHeight = 170.0;

    // 计算菜单左上角位置
    // 水平方向：默认对齐按钮左侧
    double left = offset.dx;
    // 垂直方向：默认显示在按钮下方，间距 4 像素
    double top = offset.dy + size.height + 4;

    // 右边界检测：如果菜单超出屏幕右侧，向左调整
    // 留出 8 像素的右边距
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    // 下边界检测：如果菜单超出屏幕底部，改为显示在按钮上方
    // 向上偏移：菜单高度 + 4 像素间距
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    // 创建 Overlay 覆盖层
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 背景遮罩：点击空白区域关闭菜单
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 下拉菜单本体
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              // 阻止点击事件穿透到遮罩层
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: AutoDownloadSettingsDropdown(
                onItemSelected: _hideDropdown,
              ),
            ),
          ),
        ],
      ),
    );

    // 将覆盖层插入到 Overlay 中
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsDropdownButton(
          key: _buttonKey,
          label: '每个节目最新 3 集',
          onPressed: _showDropdown,
        ),
        const SizedBox(height: 4.0),
        const Text(
          '自动下载最新单集供离线收听',
          style: TextStyle(
            color: Color.fromARGB(217, 160, 160, 160),
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}
