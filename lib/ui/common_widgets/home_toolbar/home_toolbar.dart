import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/home_toolbar_button.dart';

/// 主页工具栏
///
/// 位于主页底部的工具栏，提供主要功能的快速访问入口。
/// 包含添加任务、番茄钟/闹钟、以及侧边栏设置等功能按钮。
class HomeToolbar extends StatelessWidget {
  const HomeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Container 设置背景色和内边距，确保工具栏在视觉上与周围内容区分开
    return Container(
      // color: const Color(0xFFFFFFFF), // 白色背景
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 宽度自适应内容，保持紧凑
        children: [
          // 添加按钮
          // 用于快速创建新的任务或项目
          HomeToolbarButton(
            icon: const Icon(LucideIcons.plus),
            // label: 'Add', // 暂时隐藏标签，仅显示图标
            onPressed: () {
              debugPrint('Add pressed');
            },
          ),
          const SizedBox(width: 8), // 按钮之间的间距
          // 闹钟/专注按钮
          // 用于进入番茄钟或定时器功能
          HomeToolbarButton(
            icon: const Icon(LucideIcons.alarmClock), // 使用 Lucide 图标库的闹钟图标
            // label: '闹钟', // 暂时隐藏标签
            onPressed: () {
              debugPrint('Timer pressed');
            },
          ),
          const SizedBox(width: 8),

          // 侧边栏按钮
          // 用于打开侧边栏或设置页面
          HomeToolbarButton(
            icon: const Icon(LucideIcons.panelLeftOpen), // 使用 Lucide 图标库的侧边栏图标
            // label: 'Settings', // 暂时隐藏标签
            onPressed: () {
              debugPrint('Settings pressed');
            },
          ),
        ],
      ),
    );
  }
}
