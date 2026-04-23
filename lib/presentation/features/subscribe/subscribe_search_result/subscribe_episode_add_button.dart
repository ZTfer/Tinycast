import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/search/podcast_search_provider.dart';
import 'package:tinycast/domain/entities/podcast.dart';

/// 订阅添加按钮组件
///
/// 用于播客搜索结果列表中，让用户添加/订阅某个播客。
///
/// ## 状态机
/// 按钮有三种互斥状态：
/// 1. **可点击**（默认）：显示 "+" 号，点击后触发订阅流程
/// 2. **添加中**：显示加载动画，点击无效，防止重复提交
/// 3. **已订阅**：显示绿色背景 + "✓" 号，点击无效
///
/// ## 架构设计
/// - [SubscribeEpisodeAddButton]：`ConsumerWidget`，负责从 Riverpod 获取订阅状态
/// - [_SubscribeEpisodeAddButtonWidget]：`StatefulWidget`，负责处理悬停/按下的 UI 交互
///
/// 拆分原因：Riverpod 的 `ref.watch` 在 `ConsumerWidget.build` 中使用，
/// 而悬停/按下状态是纯 UI 交互，不需要重新构建整个 Provider 树，
/// 因此拆分为两个组件避免不必要的 Provider 重算。
class SubscribeEpisodeAddButton extends ConsumerWidget {
  /// 播客信息，用于获取 RSS URL 判断订阅状态
  final Podcast podcast;

  /// 按钮点击的回调函数
  ///
  /// 点击后通常触发 `PodcastSearchNotifier.addPodcast()` 开始订阅流程。
  /// 订阅期间按钮自动显示加载动画，点击无效。
  final VoidCallback? onPressed;

  /// 图标大小（"+" 号），默认 16
  ///
  /// 仅未订阅状态有效。已订阅显示固定的 16px "✓"，
  /// 添加中显示 16x16 的 `CircularProgressIndicator`。
  final double iconSize;

  /// 按钮水平内边距，默认 4
  final double horizontalPadding;

  /// 按钮垂直内边距，默认 4
  final double verticalPadding;

  /// 圆角大小，默认 16（使按钮呈现胶囊形状）
  final double borderRadius;

  /// 按钮宽度，默认 28
  final double width;

  /// 按钮高度，默认 28
  final double height;

  /// 自定义图标（仅在未订阅状态下使用）
  ///
  /// 如果为 null，则使用默认的 Lucide "+" 号。
  /// 可用于替换为其他图标或自定义 Widget。
  final Widget? icon;

  /// 创建订阅添加按钮
  const SubscribeEpisodeAddButton({
    super.key,
    required this.podcast,
    this.onPressed,
    this.iconSize = 16,
    this.horizontalPadding = 4,
    this.verticalPadding = 4,
    this.borderRadius = 16,
    this.width = 28,
    this.height = 28,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听订阅添加状态（map 类型，key 为 RSS URL，value 为是否正在添加）
    final addingStatus = ref.watch(podcastSearchAddingStatusProvider);
    final isAdding = addingStatus[podcast.rssUrl] ?? false;

    // 读取当前是否已订阅该播客
    final isSubscribed = ref
        .read(podcastSearchProvider.notifier)
        .isPodcastSubscribed(podcast.rssUrl);

    // 将状态数据传递给纯 UI 组件渲染
    return _SubscribeEpisodeAddButtonWidget(
      podcast: podcast,
      onPressed: onPressed,
      isAdding: isAdding,
      isSubscribed: isSubscribed,
      iconSize: iconSize,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      borderRadius: borderRadius,
      width: width,
      height: height,
      icon: icon,
    );
  }
}

/// 订阅添加按钮的纯 UI 实现
///
/// 不依赖任何 Provider，只负责渲染按钮的视觉状态和交互反馈。
/// 接收所有必要的状态数据（isAdding、isSubscribed）作为参数。
class _SubscribeEpisodeAddButtonWidget extends StatefulWidget {
  final Podcast podcast;
  final VoidCallback? onPressed;
  final bool isAdding;
  final bool isSubscribed;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double width;
  final double height;
  final Widget? icon;

  const _SubscribeEpisodeAddButtonWidget({
    required this.podcast,
    this.onPressed,
    required this.isAdding,
    required this.isSubscribed,
    this.iconSize = 16,
    this.horizontalPadding = 4,
    this.verticalPadding = 4,
    this.borderRadius = 16,
    this.width = 28,
    this.height = 28,
    this.icon,
  });

  @override
  State<_SubscribeEpisodeAddButtonWidget> createState() =>
      _SubscribeEpisodeAddButtonWidgetState();
}

/// 按钮 UI 状态管理
///
/// 跟踪鼠标悬停（_isHovering）和按下（_isPressed）状态，
/// 用于实现按钮的背景色过渡动画效果。
class _SubscribeEpisodeAddButtonWidgetState
    extends State<_SubscribeEpisodeAddButtonWidget> {
  /// 鼠标是否悬停在按钮上（用于悬停高亮效果）
  bool _isHovering = false;

  /// 鼠标是否按下按钮（用于按下态深色效果）
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // 鼠标进入按钮区域 → 设置悬停状态 → 触发背景色过渡动画
      onEnter: (_) => setState(() => _isHovering = true),
      // 鼠标离开按钮区域 → 清除悬停状态 → 恢复默认背景色
      onExit: (_) => setState(() => _isHovering = false),
      // 鼠标指针形状：手指图标，提示可点击
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // 按下时 → 深色背景（视觉反馈）
        onTapDown: (_) => setState(() => _isPressed = true),
        // 松开时 → 恢复悬停背景色
        onTapUp: (_) => setState(() => _isPressed = false),
        // 取消时（如滑出区域）→ 恢复悬停背景色
        onTapCancel: () => setState(() => _isPressed = false),
        // 点击回调：仅在可点击状态下（非添加中 + 未订阅）触发
        onTap: (widget.isAdding || widget.isSubscribed)
            ? null
            : widget.onPressed,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedContainer(
            // 悬停时 200ms 过渡动画，非悬停时瞬间切换
            duration: _isHovering
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding,
              vertical: widget.verticalPadding,
            ),
            decoration: BoxDecoration(
              // 根据当前状态计算背景色
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            // 按钮内容：三种互斥状态
            child: widget.isAdding
                // 状态 1：添加中 → 显示白色加载动画
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFFFFF),
                      ),
                    ),
                  )
                : widget.isSubscribed
                // 状态 2：已订阅 → 显示白色 "✓" 号
                ? const Icon(
                    LucideIcons.check,
                    size: 16,
                    color: Color(0xFFFFFFFF),
                  )
                // 状态 3：未订阅 → 显示白色 "+" 号（或自定义图标）
                : widget.icon ??
                      Icon(
                        LucideIcons.plus,
                        size: widget.iconSize,
                        color: _getContentColor(),
                      ),
          ),
        ),
      ),
    );
  }

  /// 计算按钮背景色
  ///
  /// 优先级从高到低：
  /// 1. 添加中 → 纯黑 (#000000)
  /// 2. 已订阅 → 绿色 (#4CAF50)，视觉上区分已完成状态
  /// 3. 按下态 → 纯黑 (#000000)，比悬停更深
  /// 4. 悬停态 → 深灰 (#111111)，比默认略亮
  /// 5. 默认态 → 深灰 (#222222)
  Color _getBackgroundColor() {
    if (widget.isAdding) return const Color(0xFF000000);
    if (widget.isSubscribed) return const Color(0xFF4CAF50);
    if (_isPressed) return const Color(0xFF000000);
    if (_isHovering) return const Color(0xFF111111);
    return const Color(0xFF222222);
  }

  /// 计算按钮内容（图标/加载动画）颜色
  ///
  /// 所有状态下均为白色 (#FFFFFF)，确保在深色背景上有足够的对比度。
  Color _getContentColor() {
    return const Color(0xFFFFFFFF);
  }
}
