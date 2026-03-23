import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';

class QueuePlayPauseButton extends ConsumerWidget {
  final int episodeId;
  final String label;
  final VoidCallback onPressed;

  const QueuePlayPauseButton({
    super.key,
    required this.episodeId,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playbackProvider);
    final currentEpisodeId = playerState.currentEpisode?.id;
    final isPlaying = playerState.isPlaying;

    final isCurrentEpisode = currentEpisodeId == episodeId;
    final showPauseIcon = isCurrentEpisode && isPlaying;

    return _QueuePlayPauseButtonContent(
      showPauseIcon: showPauseIcon,
      label: label,
      onPressed: onPressed,
    );
  }
}

class _QueuePlayPauseButtonContent extends StatefulWidget {
  final bool showPauseIcon;
  final String label;
  final VoidCallback onPressed;

  const _QueuePlayPauseButtonContent({
    required this.showPauseIcon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_QueuePlayPauseButtonContent> createState() {
    return _QueuePlayPauseButtonContentState();
  }
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
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.showPauseIcon ? LucideIcons.pause : LucideIcons.play,
                size: 10,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF000000),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 10,
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
