import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/theme/theme_data.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';

class PlayPauseButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const PlayPauseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);

    return _PlayPauseButtonContent(isPlaying: isPlaying, onPressed: onPressed);
  }
}

class _PlayPauseButtonContent extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayPauseButtonContent({
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  State<_PlayPauseButtonContent> createState() =>
      _PlayPauseButtonContentState();
}

class _PlayPauseButtonContentState extends State<_PlayPauseButtonContent> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
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
            color: _getBackgroundColor(theme),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: SvgPicture.asset(
            widget.isPlaying
                ? 'assets/gravity_icons/pause-fill.svg'
                : 'assets/gravity_icons/play-fill.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              _getContentColor(theme),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(AppThemeData theme) {
    if (_isPressed) return theme.playPauseButtonPressedBackground;
    if (_isHovering) return theme.playPauseButtonHoverBackground;
    return theme.playPauseButtonDefaultBackground;
  }

  Color _getContentColor(AppThemeData theme) {
    return theme.playPauseButtonContentColor;
  }
}
