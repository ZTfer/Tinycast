import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../data/database/isar_service.dart';
import '../../../data/models/podcast_model.dart' as model;
import '../../../data/models/episode_model.dart' as model;
import '../../../core/utils/logger.dart';

class DatabaseCleanupPage extends ConsumerWidget {
  const DatabaseCleanupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '数据库清理工具',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '此工具将清理数据库中的未订阅播客：\n'
            '1. 删除所有 isSubscribed = false 的播客\n'
            '2. 删除这些播客的所有剧集数据\n'
            '3. 保留已订阅的播客和剧集',
            style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _cleanupDatabase(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '清理未订阅播客',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showDatabaseStatus(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '查看数据库状态',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupDatabase(BuildContext context) async {
    try {
      Logger.info('开始清理数据库');

      final isar = IsarService.instance.isar;

      final result = await isar.writeTxn(() async {
        final unsubscribedPodcasts = await isar.podcasts
            .filter()
            .isSubscribedEqualTo(false)
            .findAll();

        Logger.info('找到 ${unsubscribedPodcasts.length} 个未订阅播客');

        int deletedEpisodes = 0;

        for (final podcast in unsubscribedPodcasts) {
          Logger.info('删除播客: ${podcast.title}, ID: ${podcast.id}');

          final episodeCount = await isar.episodes
              .filter()
              .podcastIdEqualTo(podcast.id)
              .deleteAll();

          deletedEpisodes += episodeCount;
          Logger.info('删除了 $episodeCount 个剧集');

          await isar.podcasts.delete(podcast.id);
        }

        return {
          'deletedPodcasts': unsubscribedPodcasts.length,
          'deletedEpisodes': deletedEpisodes,
        };
      });

      Logger.info('数据库清理完成');

      if (context.mounted) {
        _showMessage(
          context,
          '清理完成！删除了 ${result['deletedPodcasts']} 个播客和 ${result['deletedEpisodes']} 个剧集',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('清理数据库失败', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        _showMessage(context, '清理失败: $e');
      }
    }
  }

  Future<void> _showDatabaseStatus(BuildContext context) async {
    try {
      final isar = IsarService.instance.isar;
      final allPodcasts = await isar.podcasts.where().findAll();
      final allEpisodes = await isar.episodes.where().findAll();

      final subscribedPodcasts = allPodcasts
          .where((p) => p.isSubscribed)
          .toList();
      final unsubscribedPodcasts = allPodcasts
          .where((p) => !p.isSubscribed)
          .toList();

      final buffer = StringBuffer();
      buffer.writeln('数据库状态:');
      buffer.writeln('总播客数: ${allPodcasts.length}');
      buffer.writeln('已订阅: ${subscribedPodcasts.length}');
      buffer.writeln('未订阅: ${unsubscribedPodcasts.length}');
      buffer.writeln('总剧集数: ${allEpisodes.length}');
      buffer.writeln('');

      if (subscribedPodcasts.isNotEmpty) {
        buffer.writeln('已订阅播客:');
        for (final p in subscribedPodcasts) {
          buffer.writeln('  ✓ ${p.title} (ID: ${p.id})');
        }
        buffer.writeln('');
      }

      if (unsubscribedPodcasts.isNotEmpty) {
        buffer.writeln('未订阅播客:');
        for (final p in unsubscribedPodcasts) {
          buffer.writeln('  ✗ ${p.title} (ID: ${p.id})');
        }
      }

      if (context.mounted) {
        _showDialog(context, '数据库状态', buffer.toString());
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, '查询失败: $e');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '关闭',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
