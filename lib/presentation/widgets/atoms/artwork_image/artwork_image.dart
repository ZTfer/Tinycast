import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/services/file_storage_service.dart';

class ArtworkImage extends StatelessWidget {
  final String? artworkPath;
  final String? artworkUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;

  const ArtworkImage({
    super.key,
    this.artworkPath,
    this.artworkUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    this.errorWidget = const Icon(Icons.broken_image, color: Colors.grey, size: 24),
  });

  ArtworkImage.fromEpisode(
    Episode episode, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    this.errorWidget = const Icon(Icons.broken_image, color: Colors.grey, size: 24),
  })  : artworkPath = episode.artworkPath,
        artworkUrl = episode.artworkUrl;

  ArtworkImage.fromPodcast(
    Podcast podcast, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    this.errorWidget = const Icon(Icons.broken_image, color: Colors.grey, size: 24),
  })  : artworkPath = podcast.artworkPath,
        artworkUrl = podcast.artworkUrl;

  @override
  Widget build(BuildContext context) {
    if (artworkPath != null && artworkPath!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: _getLocalFile(artworkPath!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildNetworkImage(),
            );
          }
          return _buildNetworkImage();
        },
      );
    }
    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: artworkUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => errorWidget,
      );
    }
    return errorWidget;
  }

  Future<File?> _getLocalFile(String relativePath) async {
    try {
      final fullPath = await FileStorageService.instance.getFullFilePath(relativePath);
      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
