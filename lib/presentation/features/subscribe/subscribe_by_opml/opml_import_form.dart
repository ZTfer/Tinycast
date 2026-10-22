import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/core/utils/logger.dart';

/// 虚线边框绘制器
///
/// 使用 CustomPainter 绘制带圆角的虚线边框。
class DashedBorderPainter extends CustomPainter {
  /// 边框颜色
  final Color color;

  /// 边框宽度
  final double strokeWidth;

  /// 边框圆角
  final double borderRadius;

  /// 虚线模式：实线长度，空白长度
  final List<double> dashPattern;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 0.5,
    this.borderRadius = 8.0,
    this.dashPattern = const [5.0, 3.0],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final pathMetric = path.computeMetrics().first;
    final pathLength = pathMetric.length;

    double currentPosition = 0;
    int patternIndex = 0;

    while (currentPosition < pathLength) {
      final dashLength = dashPattern[patternIndex % dashPattern.length];
      final nextPosition = currentPosition + dashLength;

      if (nextPosition > pathLength) {
        final extractPath = pathMetric.extractPath(currentPosition, pathLength);
        canvas.drawPath(extractPath, paint);
        break;
      }

      if (patternIndex % 2 == 0) {
        final extractPath = pathMetric.extractPath(
          currentPosition,
          nextPosition,
        );
        canvas.drawPath(extractPath, paint);
      }

      currentPosition = nextPosition;
      patternIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius ||
        dashPattern != oldDelegate.dashPattern;
  }
}

/// OPML导入组件
///
/// 用于导入OPML文件的拖放区域。
/// 支持点击选择文件和拖放文件功能。
class OpmlImportForm extends StatefulWidget {
  /// 文件选择完成后的回调函数
  final ValueChanged<File>? onFileSelected;

  /// 组件是否可用
  final bool enabled;

  const OpmlImportForm({super.key, this.onFileSelected, this.enabled = true});

  @override
  State<OpmlImportForm> createState() => _OpmlImportFormState();
}

class _OpmlImportFormState extends State<OpmlImportForm> {
  /// 记录是否正在拖动文件
  bool _isDragging = false;

  /// 记录是否正在悬停
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      /// 判断是否接受拖放的数据
      onWillAcceptWithDetails: (details) => widget.enabled,

      /// 接受拖放的数据时的回调
      onAcceptWithDetails: (details) {
        /// 如果拖放的是文件，触发回调
        if (details.data is File) {
          widget.onFileSelected?.call(details.data as File);
        }

        /// 重置拖动状态
        setState(() {
          _isDragging = false;
        });
      },

      /// 拖放离开区域时的回调
      onLeave: (_) {
        setState(() {
          _isDragging = false;
          _isHovering = false;
        });
      },

      /// 拖放移动到区域上时的回调
      onMove: (_) {
        /// 如果不在拖动状态，设置为拖动状态
        if (!_isDragging) {
          setState(() {
            _isDragging = true;
            _isHovering = true;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return MouseRegion(
          /// 鼠标进入区域
          onEnter: (_) {
            if (widget.enabled) {
              setState(() {
                _isHovering = true;
              });
            }
          },

          /// 鼠标离开区域
          onExit: (_) {
            if (!_isDragging) {
              setState(() {
                _isHovering = false;
              });
            }
          },
          child: GestureDetector(
            /// 点击区域时触发文件选择
            onTap: widget.enabled ? _handleTap : null,
            child: CustomPaint(
              /// 使用虚线边框绘制器
              painter: DashedBorderPainter(
                /// 悬停或拖动时显示黑色边框，否则显示灰色边框
                color: (_isHovering || _isDragging)
                    ? const Color(0xFF000000)
                    : const Color(0xFF999999),

                /// 边框宽度：0.5px
                strokeWidth: 0.5,

                /// 圆角：8px
                borderRadius: 8.0,

                /// 虚线模式：5px 实线，3px 空白
                dashPattern: const [5.0, 3.0],
              ),
              child: Container(
                /// 容器装饰样式
                decoration: BoxDecoration(
                  /// 背景色：浅灰色
                  color: const Color(0xFFF0F0F0),

                  /// 圆角：8px
                  borderRadius: BorderRadius.circular(8.0),
                ),

                /// 内边距：水平160px，垂直52px
                padding: const EdgeInsets.symmetric(
                  horizontal: 60.0,
                  vertical: 48.0,
                ),
                child: Column(
                  /// 主轴尺寸：最小
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// 上传图标
                    Icon(
                      /// 使用 Lucide 的 upload 图标
                      LucideIcons.upload,

                      /// 图标大小：16px
                      size: 16.0,

                      /// 图标颜色：黑色80%透明度
                      color: const Color(0xCC000000),
                    ),

                    /// 间距：10px
                    const SizedBox(height: 10.0),

                    /// 提示文字
                    Align(
                      alignment: Alignment.center,

                      child: Padding(
                        /// 水平内边距：12px
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          '点击或者拖动文件到这里',
                          textAlign: TextAlign.center,
                          maxLines: null,
                          style: TextStyle(
                            /// 字体大小：10px
                            fontSize: 10.0,

                            /// 可用时显示黑色50%透明度，禁用时显示黑色25%透明度
                            color: widget.enabled
                                ? const Color(0x80000000)
                                : const Color(0x40000000),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 处理点击事件，打开文件选择器
  Future<void> _handleTap() async {
    try {
      /// 使用文件选择器选择文件
      final picked = await FilePicker.pickFile(
        /// 文件类型：自定义
        type: FileType.custom,

        /// 允许的文件扩展名：opml 和 xml
        allowedExtensions: ['opml', 'xml'],
      );

      /// 如果选择了文件且文件路径不为空
      if (picked?.path != null) {
        /// 创建文件对象
        final file = File(picked!.path!);

        /// 触发文件选择回调
        widget.onFileSelected?.call(file);
      }
    } catch (e, stackTrace) {
      Logger.error('文件选择失败', error: e, stackTrace: stackTrace);
    }
  }
}
