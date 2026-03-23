import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/core/utils/logger.dart';

class PlayPauseButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const PlayPauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    
    Logger.debug('PlayPauseButton build: isPlaying=$isPlaying');

    return _PlayPauseButtonContent(
      isPlaying: isPlaying,
      onPressed: onPressed,
      key: ValueKey('play_pause_$isPlaying'),
    );
  }
}

class _PlayPauseButtonContent extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayPauseButtonContent({
    required this.isPlaying,
    required this.onPressed,
    super.key,
  });

  @override
  State<_PlayPauseButtonContent> createState() =>
      _PlayPauseButtonContentState();
}

class _PlayPauseButtonContentState extends State<_PlayPauseButtonContent> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  void didUpdateWidget(_PlayPauseButtonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    Logger.debug('PlayPauseButton didUpdateWidget: ${oldWidget.isPlaying} -> ${widget.isPlaying}');
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('PlayPauseButtonContent build: isPlaying=${widget.isPlaying}');
    
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
          child: Icon(
            widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
            size: 24,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF000000),
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
