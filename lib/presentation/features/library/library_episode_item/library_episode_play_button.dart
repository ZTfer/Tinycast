import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';

class LibraryEpisodePlayButton extends ConsumerWidget {
  final Episode episode;
  final VoidCallback onPressed;

  const LibraryEpisodePlayButton({
    super.key,
    required this.episode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThisEpisodePlaying = ref.watch(
      playbackProvider.select(
        (state) => state.currentEpisode?.id == episode.id && state.isPlaying,
      ),
    );

    return _LibraryEpisodePlayButtonInner(
      isPlaying: isThisEpisodePlaying,
      onPressed: onPressed,
    );
  }
}

class _LibraryEpisodePlayButtonInner extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _LibraryEpisodePlayButtonInner({
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  State<_LibraryEpisodePlayButtonInner> createState() =>
      _LibraryEpisodePlayButtonInnerState();
}

class _LibraryEpisodePlayButtonInnerState
    extends State<_LibraryEpisodePlayButtonInner> {
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
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: IconTheme(
            data: const IconThemeData(color: Color(0xD9000000), size: 12),
            child: Icon(
              widget.isPlaying
                  ? LucideIcons.pause
                  : LucideIcons.play,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }
}
