import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinycast/domain/entities/episode.dart' as domain;
import 'package:tinycast/domain/entities/podcast.dart' as domain_podcast;
import 'package:tinycast/data/models/episode_model.dart' as data;
import 'package:tinycast/data/models/podcast_model.dart' as data_podcast;
import 'package:tinycast/data/services/file_storage_service.dart';
import 'package:tinycast/data/services/image_cache_service.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/core/utils/logger.dart';

class ArtworkImage extends StatefulWidget {
  final String? artworkPath;
  final String? artworkUrl;
  final domain.Episode? episode;
  final domain_podcast.Podcast? podcast;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;

  const ArtworkImage({
    super.key,
    this.artworkPath,
    this.artworkUrl,
    this.episode,
    this.podcast,
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
    domain.Episode this.episode, {
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
    this.podcast,
  })  : artworkPath = episode.artworkPath,
        artworkUrl = episode.artworkUrl;

  ArtworkImage.fromPodcast(
    domain_podcast.Podcast this.podcast, {
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
    this.episode,
  })  : artworkPath = podcast.artworkPath,
        artworkUrl = podcast.artworkUrl;

  @override
  State<ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<ArtworkImage> {
  File? _localFile;
  bool _isCheckingLocal = false;
  bool _downloadTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkAndTriggerDownload();
  }

  @override
  void didUpdateWidget(ArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkPath != widget.artworkPath ||
        oldWidget.artworkUrl != widget.artworkUrl) {
      _localFile = null;
      _downloadTriggered = false;
      _checkAndTriggerDownload();
    }
  }

  Future<void> _checkAndTriggerDownload() async {
    if (_isCheckingLocal) return;
    _isCheckingLocal = true;

    try {
      if (widget.artworkPath != null && widget.artworkPath!.isNotEmpty) {
        Logger.info('🖼️ [ArtworkImage] 检查本地文件: ${widget.artworkPath}');
        final file = await _getLocalFile(widget.artworkPath!);
        if (file != null && mounted) {
          setState(() {
            _localFile = file;
          });
          Logger.info('✅ [ArtworkImage] 本地文件存在，直接使用');
          return;
        } else {
          Logger.warning('⚠️ [ArtworkImage] 本地文件不存在: ${widget.artworkPath}');
        }
      } else {
        Logger.info('📭 [ArtworkImage] artworkPath 为空，需要从网络加载或下载');
      }
      
      if (!_downloadTriggered && mounted) {
        _triggerBackgroundDownload();
      }
    } catch (e) {
      Logger.error('❌ [ArtworkImage] 检查本地文件失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocal = false;
        });
      }
    }
  }

  void _triggerBackgroundDownload() {
    if (_downloadTriggered) return;
    _downloadTriggered = true;

    Logger.info('🚀 [ArtworkImage] 触发后台封面图下载...');

    Future.microtask(() async {
      try {
        final imageCacheService = ImageCacheService.instance;
        final isarService = IsarService.instance;
        
        if (widget.episode != null && widget.episode!.artworkUrl != null) {
          Logger.info('🎯 [ArtworkImage] 开始下载 Episode 封面图: ${widget.episode!.title}');
          Logger.info('   URL: ${widget.episode!.artworkUrl}');
          Logger.info('   Episode ID: ${widget.episode!.id}');
          
          final dataEpisode = await isarService.isar.episodes.get(widget.episode!.id);
          if (dataEpisode != null) {
            final downloadedFile = await imageCacheService.downloadAndSaveEpisodeArtwork(dataEpisode);
            
            if (downloadedFile != null && mounted) {
              setState(() {
                _localFile = downloadedFile;
              });
              Logger.info('✅ [ArtworkImage] Episode 封面图下载完成并更新UI: ${downloadedFile.path}');
            }
          } else {
            Logger.warning('⚠️ [ArtworkImage] 未找到 Episode 数据模型，ID: ${widget.episode!.id}');
          }
        } else if (widget.podcast != null && widget.podcast!.artworkUrl.isNotEmpty) {
          Logger.info('🎯 [ArtworkImage] 开始下载 Podcast 封面图: ${widget.podcast!.title}');
          Logger.info('   URL: ${widget.podcast!.artworkUrl}');
          Logger.info('   Podcast ID: ${widget.podcast!.id}');
          
          final dataPodcast = await isarService.isar.podcasts.get(widget.podcast!.id);
          if (dataPodcast != null) {
            final downloadedFile = await imageCacheService.downloadAndSavePodcastArtwork(dataPodcast);
            
            if (downloadedFile != null && mounted) {
              setState(() {
                _localFile = downloadedFile;
              });
              Logger.info('✅ [ArtworkImage] Podcast 封面图下载完成并更新UI: ${downloadedFile.path}');
            }
          } else {
            Logger.warning('⚠️ [ArtworkImage] 未找到 Podcast 数据模型，ID: ${widget.podcast!.id}');
          }
        } else {
          Logger.warning('⚠️ [ArtworkImage] 无法下载：缺少 episode/podcast 对象或 artworkUrl');
        }
      } catch (e) {
        Logger.error('❌ [ArtworkImage] 后台下载失败（不影响显示）: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localFile != null) {
      Logger.debug('🖼️ [ArtworkImage] 使用本地文件渲染: ${_localFile!.path}');
      return Image.file(
        _localFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, error, stack) {
          Logger.warning('⚠️ [ArtworkImage] 本地文件加载失败: $error');
          return _buildNetworkImage();
        },
      );
    }

    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    if (widget.artworkUrl != null && widget.artworkUrl!.isNotEmpty) {
      Logger.debug('🌐 [ArtworkImage] 使用网络图片: ${widget.artworkUrl}');
      return CachedNetworkImage(
        imageUrl: widget.artworkUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) {
          Logger.debug('⏳ [ArtworkImage] 网络图片加载中...');
          return widget.placeholder;
        },
        errorWidget: (context, url, error) {
          Logger.warning('❌ [ArtworkImage] 网络图片加载失败: $error');
          return widget.errorWidget;
        },
      );
    }
    
    Logger.warning('⚠️ [ArtworkImage] 无可用的图片URL');
    return widget.errorWidget;
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
      Logger.error('❌ [ArtworkImage] 获取本地文件失败: $e');
      return null;
    }
  }
}
