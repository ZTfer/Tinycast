import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';

class QueuePlayPauseButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  const QueuePlayPauseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconSize = 10,
    this.fontSize = 10,
    this.horizontalPadding = 8,
    this.verticalPadding = 4,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);

    return _QueuePlayPauseButtonContent(
      isPlaying: isPlaying,
      label: label,
      onPressed: onPressed,
      iconSize: iconSize,
      fontSize: fontSize,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      borderRadius: borderRadius,
    );
  }
}

class _QueuePlayPauseButtonContent extends StatefulWidget {
  final bool isPlaying;
  final String label;
  final VoidCallback onPressed;
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  const _QueuePlayPauseButtonContent({
    required this.isPlaying,
    required this.label,
    required this.onPressed,
    required this.iconSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
  });

  @override
  State<_QueuePlayPauseButtonContent> createState() =>
      _QueuePlayPauseButtonContentState();
}

class _QueuePlayPauseButtonContentState
    extends State<_QueuePlayPauseButtonContent> {
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
        onTap: widget.onPressed,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
                size: widget.iconSize,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF000000),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: const Color(0xFF000000),
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFDADADA);
    if (_isHovering) return const Color(0xFFE1E1E1);
    return const Color(0xFFEEEEEE);
  }
}
