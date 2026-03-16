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
  /// 是否正在拖动
  bool _isDragging = false;

  /// 拖动过程中的临时进度值 (0.0 ~ 1.0)
  double _dragValue = 0.0;

  /// 是否悬停在进度条上
  bool _isHovering = false;

  /// 当前的音量比例 (0.0 ~ 1.0)
  ///
  /// 如果正在拖动，返回拖动过程中的临时值
  /// 否则根据当前音量值计算比例
  double get _progress {
    if (_isDragging) return _dragValue;
    return (widget.volume / 100.0).clamp(0.0, 1.0);
  }

  /// 根据手势位置计算进度值
  ///
  /// 将手势的 x 坐标转换为进度比例 (0.0 ~ 1.0)
  double _calcProgress(Offset localPosition, double trackWidth) {
    return (localPosition.dx / trackWidth).clamp(0.0, 1.0);
  }

  /// 将进度值换算为音量值 (0 ~ 100)
  ///
  /// 将 0.0 ~ 1.0 的进度值转换为 0 ~ 100 的音量值
  int _progressToVolume(double progress) {
    return (progress * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 固定宽度为 140
      width: 140,
      // 内边距为 4
      padding: const EdgeInsets.all(4.0),
      // 容器装饰：白色背景、圆角、边框、阴影
      decoration: BoxDecoration(
        // 白色背景
        color: Color(0xFFFFFFFF),
        // 圆角半径 12
        borderRadius: BorderRadius.circular(12.0),
        // 边框样式
        border: Border.all(
          color: Color(0xFFE0E0E0), // 边框颜色
          width: 0.5, // 边框宽度
          style: BorderStyle.solid, // 实线
        ),
        // 阴影效果
        boxShadow: [
          BoxShadow(
            // 黑色半透明阴影
            color: Color(0xFF000000).withValues(alpha: 0.1),
            // 模糊半径 8
            blurRadius: 8.0,
            // 阴影向下偏移 8
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        // 水平内边距 16
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MouseRegion(
          // 鼠标悬停时显示点击光标
          cursor: SystemMouseCursors.click,
          // 鼠标进入时设置悬停状态
          onEnter: (_) => setState(() => _isHovering = true),
          // 鼠标离开时取消悬停状态
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            // 点击时跳转到指定音量位置
            onTapDown: (details) {
              // 获取当前组件的 RenderBox
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              // 获取轨道宽度
              final trackWidth = box.size.width;
              // 计算点击位置对应的进度
              final progress = _calcProgress(details.localPosition, trackWidth);
              // 调用回调，更新音量
              widget.onVolumeChanged?.call(_progressToVolume(progress));
            },
            // 开始水平拖动
            onHorizontalDragStart: (details) {
              setState(() {
                // 设置拖动状态为 true
                _isDragging = true;
                // 获取当前组件的 RenderBox
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                // 计算拖动开始位置对应的进度
                _dragValue = _calcProgress(
                  details.localPosition,
                  box.size.width,
                );
              });
            },
            // 拖动过程中更新进度
            onHorizontalDragUpdate: (details) {
              setState(() {
                // 获取当前组件的 RenderBox
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                // 计算拖动位置对应的进度
                _dragValue = _calcProgress(
                  details.localPosition,
                  box.size.width,
                );
              });
            },
            // 结束拖动
            onHorizontalDragEnd: (details) {
              // 调用回调，更新音量到最终值
              widget.onVolumeChanged?.call(_progressToVolume(_dragValue));
              // 设置拖动状态为 false
              setState(() => _isDragging = false);
            },
            child: SizedBox(
              // 高度为拖动手柄直径加上边距
              height: widget.thumbRadius * 2 + 8,
              child: CustomPaint(
                painter: _ProgressTrackPainter(
                  progress: _progress,
                  trackColor: widget.trackColor,
                  progressColor: widget.progressColor,
                  thumbColor: widget.thumbColor,
                  trackHeight: widget.trackHeight,
                  thumbRadius: widget.thumbRadius,
                  // 悬停或拖动时显示拖动手柄
                  showThumb: _isDragging || _isHovering,
                ),
                // 无限大小，由父容器约束
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 自定义画笔 — 绘制进度轨道、已播放进度和拖动手柄
///
/// 使用 CustomPainter 自定义绘制音量控制条，包括：
/// 1. 底部轨道（未播放部分）
/// 2. 进度部分（已播放部分）
/// 3. 拖动手柄（悬停或拖动时显示）
class _ProgressTrackPainter extends CustomPainter {
  /// 当前进度比例 (0.0 ~ 1.0)
  final double progress;

  /// 轨道颜色
  final Color trackColor;

  /// 进度颜色
  final Color progressColor;

  /// 拖动手柄颜色
  final Color thumbColor;

  /// 轨道高度
  final double trackHeight;

  /// 拖动手柄半径
  final double thumbRadius;

  /// 是否显示拖动手柄
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
    // 计算垂直中心位置
    final centerY = size.height / 2;
    // 计算轨道的圆角半径
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
      // 在进度末端绘制圆形手柄
      canvas.drawCircle(
        Offset(progressWidth, centerY),
        thumbRadius,
        thumbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressTrackPainter oldDelegate) {
    // 当任何属性变化时都需要重绘
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.trackHeight != trackHeight ||
        oldDelegate.thumbRadius != thumbRadius ||
        oldDelegate.showThumb != showThumb;
  }
}
