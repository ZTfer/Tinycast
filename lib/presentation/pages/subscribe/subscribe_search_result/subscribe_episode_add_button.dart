import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/podcast_search_provider.dart';
import 'package:tinycast/domain/entities/podcast.dart';

class SubscribeEpisodeAddButton extends ConsumerWidget {
  /// 播客信息
  final Podcast podcast;

  /// 按钮点击的回调函数
  final VoidCallback? onPressed;

  /// 图标大小，默认 16
  final double iconSize;

  /// 水平内边距，默认 4
  final double horizontalPadding;

  /// 垂直内边距，默认 4
  final double verticalPadding;

  /// 圆角大小，默认 16
  final double borderRadius;

  /// 按钮宽度，默认 28
  final double width;

  /// 按钮高度，默认 28
  final double height;

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addingStatus = ref.watch(podcastSearchAddingStatusProvider);
    final isAdding = addingStatus[podcast.rssUrl] ?? false;
    final isSubscribed = ref.read(podcastSearchProvider.notifier).isPodcastSubscribed(podcast.rssUrl);

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
    );
  }
}

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
  });

  @override
  State<_SubscribeEpisodeAddButtonWidget> createState() =>
      _SubscribeEpisodeAddButtonWidgetState();
}

class _SubscribeEpisodeAddButtonWidgetState extends State<_SubscribeEpisodeAddButtonWidget> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: (widget.isAdding || widget.isSubscribed) ? null : widget.onPressed,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedContainer(
            duration: _isHovering
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding,
              vertical: widget.verticalPadding,
            ),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.isAdding
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
                    ? const Icon(
                        LucideIcons.check,
                        size: 16,
                        color: Color(0xFFFFFFFF),
                      )
                    : Icon(
                        LucideIcons.plus,
                        size: widget.iconSize,
                        color: _getContentColor(),
                      ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isAdding) return const Color(0xFF000000);
    if (widget.isSubscribed) return const Color(0xFF4CAF50);
    if (_isPressed) return const Color(0xFF000000);
    if (_isHovering) return const Color(0xFF111111);
    return const Color(0xFF222222);
  }

  Color _getContentColor() {
    return const Color(0xFFFFFFFF);
  }
}
