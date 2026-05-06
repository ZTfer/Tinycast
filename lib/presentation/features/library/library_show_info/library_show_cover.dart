import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

class LibraryShowCover extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final double borderRadius;
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
    return ArtworkImage(
      artworkUrl: artworkUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
    );
  }
}
