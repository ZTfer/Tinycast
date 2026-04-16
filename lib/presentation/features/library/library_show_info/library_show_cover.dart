import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

/// Library 节目封面组件
///
/// 用于显示节目封面。
/// 支持显示实际图片或使用占位符。
class LibraryShowCover extends StatelessWidget {
  /// 封面宽度，默认 34
  final double width;

  /// 封面高度，默认 34
  final double height;

  /// 封面背景颜色，默认灰色
  final Color backgroundColor;

  /// 圆角大小，默认 6
  final double borderRadius;

  /// 封面图片 URL
  final String? artworkUrl;

  const LibraryShowCover({
    super.key,
    this.width = 34,
    this.height = 34,
    this.backgroundColor = const Color(0xFFD9D9D9),
    this.borderRadius = 6,
    this.artworkUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: ArtworkImage(
          artworkUrl: artworkUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholder(),
          errorWidget: _buildPlaceholder(),
        ),
      ),
    );
  }

  /// 构建占位图
  Widget _buildPlaceholder() {
    return SvgPicture.asset(
      'assets/images/image_placeholder.svg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
