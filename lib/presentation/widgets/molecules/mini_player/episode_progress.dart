import 'package:flutter/widgets.dart';

/// 音频播放进度条
///
/// 显示当前播放进度、总时长，支持拖动手势调整播放位置。
/// 使用 [CustomPainter] 绘制进度轨道和拖动手柄，不依赖 Material 组件。
class EpisodeProgress extends StatefulWidget {
  /// 当前播放位置
  final Duration position;

  /// 音频总时长
  final Duration duration;

  /// 用户拖动或点击调整播放位置时的回调
  final ValueChanged<Duration>? onSeek;

  /// 进度条轨道的颜色（未播放部分）
  final Color trackColor;

  /// 进度条已播放部分的颜色
  final Color progressColor;

  /// 拖动手柄的颜色
  final Color thumbColor;

  /// 时间标签的文字样式
  final TextStyle? timeLabelStyle;

  /// 进度条轨道高度
  final double trackHeight;

  /// 拖动手柄的半径
  final double thumbRadius;

  const EpisodeProgress({
    super.key,
    this.position = Duration.zero,
    this.duration = const Duration(minutes: 1),
    this.onSeek,
    this.trackColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF333333),
    this.thumbColor = const Color(0xFF333333),
    this.timeLabelStyle,
    this.trackHeight = 3.0,
    this.thumbRadius = 6.0,
  });

  @override
  State<EpisodeProgress> createState() => _EpisodeProgressState();
}

class _EpisodeProgressState extends State<EpisodeProgress> {
  /// 是否正在拖动
  bool _isDragging = false;

  /// 拖动过程中的临时进度值 (0.0 ~ 1.0)
  double _dragValue = 0.0;

  /// 是否悬停在进度条上
  bool _isHovering = false;

  /// 当前的进度比例 (0.0 ~ 1.0)
  double get _progress {
    if (_isDragging) return _dragValue;
    if (widget.duration.inMilliseconds == 0) return 0.0;
    return (widget.position.inMilliseconds / widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  /// 根据手势位置计算进度值
  double _calcProgress(Offset localPosition, double trackWidth) {
    return (localPosition.dx / trackWidth).clamp(0.0, 1.0);
  }

  /// 将进度值换算为 Duration
  Duration _progressToDuration(double progress) {
    final ms = (progress * widget.duration.inMilliseconds).round();
    return Duration(milliseconds: ms);
  }

  /// 格式化时间为 mm:ss 或 hh:mm:ss
  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTimeLabelStyle =
        widget.timeLabelStyle ??
        const TextStyle(fontSize: 11, color: Color(0xFF999999));

    final displayPosition = _isDragging
        ? _progressToDuration(_dragValue)
        : widget.position;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条轨道区域
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              // 点击跳转到对应位置
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final trackWidth = box.size.width;
                final progress = _calcProgress(
                  details.localPosition,
                  trackWidth,
                );
                widget.onSeek?.call(_progressToDuration(progress));
              },
              // 水平拖动手势 — 开始
              onHorizontalDragStart: (details) {
                setState(() {
                  _isDragging = true;
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  _dragValue = _calcProgress(
                    details.localPosition,
                    box.size.width,
                  );
                });
              },
              // 水平拖动手势 — 更新
              onHorizontalDragUpdate: (details) {
                setState(() {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  _dragValue = _calcProgress(
                    details.localPosition,
                    box.size.width,
                  );
                });
              },
              // 水平拖动手势 — 结束
              onHorizontalDragEnd: (details) {
                widget.onSeek?.call(_progressToDuration(_dragValue));
                setState(() => _isDragging = false);
              },
              child: SizedBox(
                height: widget.thumbRadius * 2 + 8, // 足够的触摸/点击区域
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

          const SizedBox(height: 2),

          // 时间标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(displayPosition),
                style: effectiveTimeLabelStyle,
              ),
              Text(
                _formatDuration(widget.duration),
                style: effectiveTimeLabelStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 自定义画笔 — 绘制进度轨道、已播放进度和拖动手柄
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

    // 绘制底部轨道（未播放部分）
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

    // 绘制进度部分（已播放部分）
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

    // 绘制拖动手柄（悬停或拖动时显示）
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
