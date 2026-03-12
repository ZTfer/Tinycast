import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_tab/subscribe_tab_button.dart';

/// 订阅页面顶部标签栏组件
///
/// 用于在订阅页面顶部显示可切换的标签按钮，支持 RSS 和 OPML 两种订阅方式。
/// 点击不同的标签按钮会触发页面切换回调。
class SubscribeTab extends StatelessWidget {
  /// 当前选中的页面标识
  final String currentPage;

  /// 页面切换时的回调函数，接收页面标识作为参数
  final Function(String) onPageChanged;

  const SubscribeTab({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      /// 占据父容器的全部宽度
      width: double.infinity,

      /// 容器装饰样式
      decoration: const BoxDecoration(
        /// 背景色：白色
        color: Color(0xFFFFFFFF),

        /// 左上角圆角
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: Column(
        children: [
          /// 顶部间距
          const SizedBox(height: 12),

          /// 横向排列的标签按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// RSS 订阅标签按钮
              _buildTabbarButton(
                icon: LucideIcons.rss,
                label: 'RSS',

                /// 根据当前页面判断按钮状态
                state: currentPage == 'rss'
                    ? SubscribeTabButtonState.iconActive
                    : SubscribeTabButtonState.defaultState,

                /// 点击时切换到 RSS 页面
                onPressed: () => onPageChanged('rss'),
              ),

              /// OPML 订阅标签按钮
              _buildTabbarButton(
                icon: LucideIcons.layoutGrid,
                label: 'OPML',

                /// 根据当前页面判断按钮状态
                state: currentPage == 'opml'
                    ? SubscribeTabButtonState.iconActive
                    : SubscribeTabButtonState.defaultState,

                /// 点击时切换到 OPML 页面
                onPressed: () => onPageChanged('opml'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标签按钮的辅助方法
  ///
  /// 为按钮添加统一的内边距，并创建 SubscribeTabButton 组件。
  Widget _buildTabbarButton({
    /// 按钮图标
    required IconData icon,

    /// 按钮文字标签
    String? label,

    /// 按钮状态，默认为默认状态
    SubscribeTabButtonState state = SubscribeTabButtonState.defaultState,

    /// 按钮点击回调
    required VoidCallback onPressed,
  }) {
    return Padding(
      /// 水平和垂直方向的内边距
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SubscribeTabButton(
        icon: icon,
        label: label,
        state: state,
        onPressed: onPressed,
      ),
    );
  }
}
