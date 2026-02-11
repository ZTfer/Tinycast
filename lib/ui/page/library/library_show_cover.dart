import 'package:flutter/widgets.dart';

/// Library 节目封面组件
///
/// 用于显示节目封面的占位符组件。
/// 目前使用灰色背景作为占位，后续可以替换为实际图片。
class LibraryShowCover extends StatelessWidget {
  /// 封面宽度，默认 34
  final double width;

  /// 封面高度，默认 34
  final double height;

  /// 封面背景颜色，默认灰色
  final Color backgroundColor;

  /// 圆角大小，默认 6
  final double borderRadius;

  const LibraryShowCover({
    super.key,
    this.width = 34,
    this.height = 34,
    this.backgroundColor = const Color(0xFFD9D9D9),
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
