import 'package:flutter/widgets.dart';

/// 音量控制条
///
/// 显示当前音量大小，支持拖动手势调整音量大小。
/// 使用 [CustomPainter] 绘制进度轨道和拖动手柄，不依赖 Material 组件。
/// 音量范围为 0 ~ 100，默认值为 30。
///
/// 功能特性：
/// - 支持点击跳转到指定音量位置
/// - 支持拖动调整音量
/// - 悬停时显示拖动手柄
/// - 拖动时显示拖动手柄
/// - 拖动时实时更新音量
/// - 使用自定义绘制，性能高效
class VolumeControlBar extends StatefulWidget {
  /// 当前音量值 (0 ~ 100)
  final int volume;

  /// 用户拖动或点击调整音量时的回调
  ///
  /// 参数为新的音量值，范围 0-100
  final ValueChanged<int>? onVolumeChanged;

  /// 进度条轨道的颜色（未播放部分）
  final Color trackColor;

  /// 进度条已播放部分的颜色
  final Color progressColor;

  /// 拖动手柄的颜色
  final Color thumbColor;

  /// 进度条轨道高度
  final double trackHeight;

  /// 拖动手柄的半径
  final double thumbRadius;

  const VolumeControlBar({
    super.key,
    this.volume = 30,
    this.onVolumeChanged,
    this.trackColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF333333),
    this.thumbColor = const Color(0xFF333333),
    this.trackHeight = 3.0,
    this.thumbRadius = 6.0,
  });

  @override
  State<VolumeControlBar> createState() => _VolumeControlBarState();
}

class _VolumeControlBarState extends State<VolumeControlBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isHovering = false;

  double get _progress {
    if (_isDragging) return _dragValue;
    return (widget.volume / 100.0).clamp(0.0, 1.0);
  }

  double _calcProgress(Offset localPosition, double trackWidth) {
    return (localPosition.dx / trackWidth).clamp(0.0, 1.0);
  }

  int _progressToVolume(double progress) {
    return (progress * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 0.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final trackWidth = box.size.width;
              final progress = _calcProgress(details.localPosition, trackWidth);
              widget.onVolumeChanged?.call(_progressToVolume(progress));
            },
            onHorizontalDragStart: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              setState(() {
                _isDragging = true;
                _dragValue = _calcProgress(
                  details.localPosition,
                  box.size.width,
                );
              });
              widget.onVolumeChanged?.call(_progressToVolume(_dragValue));
            },
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              setState(() {
                _dragValue = _calcProgress(
                  details.localPosition,
                  box.size.width,
                );
              });
              widget.onVolumeChanged?.call(_progressToVolume(_dragValue));
            },
            onHorizontalDragEnd: (details) {
              widget.onVolumeChanged?.call(_progressToVolume(_dragValue));
              setState(() => _isDragging = false);
            },
            child: SizedBox(
              height: widget.thumbRadius * 2 + 8,
              child: CustomPaint(
                painter: _ProgressTrackPainter(
                  progress: _progress,
                  trackColor: widget.trackColor,
                  progressColor: widget.progressColor,
                  thumbColor: widget.thumbColor,
                  trackHeight: widget.trackHeight,
                  thumbRadius: widget.thumbRadius,
                  showThumb: _isDragging || _isHovering,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressTrackPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color thumbColor;
  final double trackHeight;
  final double thumbRadius;
  final bool showThumb;

  _ProgressTrackPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.thumbColor,
    required this.trackHeight,
    required this.thumbRadius,
    required this.showThumb,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackRadius = trackHeight / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromLTRBR(
      0,
      centerY - trackRadius,
      size.width,
      centerY + trackRadius,
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final progressWidth = size.width * progress;
    if (progressWidth > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;

      final progressRect = RRect.fromLTRBR(
        0,
        centerY - trackRadius,
        progressWidth,
        centerY + trackRadius,
        Radius.circular(trackRadius),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }

    if (showThumb) {
      final thumbPaint = Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(progressWidth, centerY),
        thumbRadius,
        thumbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressTrackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.trackHeight != trackHeight ||
        oldDelegate.thumbRadius != thumbRadius ||
        oldDelegate.showThumb != showThumb;
  }
}
