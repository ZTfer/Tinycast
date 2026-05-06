import 'package:isar_community/isar.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../domain/entities/episode.dart' as domain;
import '../database/isar_service.dart';
import '../models/queue_model.dart';
import '../models/episode_model.dart' as model;

class LocalQueueDataSource {
  final IsarService _isarService;

  LocalQueueDataSource({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  Future<Queue?> _findQueueByEpisode(domain.Episode episode) async {
    final isar = _isarService.isar;

    if (episode.itunesId != null && episode.itunesId!.isNotEmpty) {
      final queue = await isar.queues
          .filter()
          .episodeITunesIdEqualTo(episode.itunesId)
          .findFirst();
      if (queue != null) return queue;
    }

    if (episode.guid != null && episode.guid!.isNotEmpty) {
      final queue = await isar.queues
          .filter()
          .episodeGuidEqualTo(episode.guid)
          .findFirst();
      if (queue != null) return queue;
    }

    return isar.queues
        .where()
        .episodeIdEqualTo(episode.id)
        .findFirst();
  }

  Future<List<Queue>> getAll() async {
    try {
      Logger.info('📋 [QUEUE-DS] 获取所有队列项');

      final items = await _isarService.isar.queues.where().findAll();
      items.sort((a, b) => a.position.compareTo(b.position));

      Logger.info('📋 [QUEUE-DS] 共获取 ${items.length} 条队列记录');
      return items;
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 获取队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('获取队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 获取队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('获取队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> addToQueue(domain.Episode episode) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始添加到队列, episodeId: ${episode.id}, guid: ${episode.guid}');

      final existing = await _findQueueByEpisode(episode);

      if (existing != null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: ${episode.id} 已存在于队列中, 跳过添加');
        return;
      }

      Queue? queueItem;

      await _isarService.isar.writeTxn(() async {
        final allItems = await _isarService.isar.queues.where().findAll();
        final maxPosition = allItems.isEmpty ? 0 : allItems.map((e) => e.position).reduce((a, b) => a > b ? a : b);

        queueItem = Queue()
          ..episodeId = episode.id
          ..episodeGuid = episode.guid
          ..episodeITunesId = episode.itunesId
          ..podcastId = episode.podcastId
          ..podcastGuid = null
          ..podcastITunesId = episode.podcastITunesId
          ..position = maxPosition + 1;

        await _isarService.isar.queues.put(queueItem!);
      });

      Logger.info('📋 [QUEUE-DS] 队列添加成功, episodeId: ${episode.id}, position: ${queueItem?.position}, id: ${queueItem?.id}');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 添加到队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('添加到队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 添加到队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('添加到队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> insertToQueueFront(domain.Episode episode) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始插播到队列最前, episodeId: ${episode.id}');

      final existing = await _findQueueByEpisode(episode);

      if (existing != null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: ${episode.id} 已存在于队列中, 先移除再插播');
        await removeFromQueue(existing.id);
      }

      final allItems = await _isarService.isar.queues.where().findAll();

      for (final item in allItems) {
        item.position += 1;
      }

      final queueItem = Queue()
        ..episodeId = episode.id
        ..episodeGuid = episode.guid
        ..episodeITunesId = episode.itunesId
        ..podcastId = episode.podcastId
        ..podcastITunesId = episode.podcastITunesId
        ..position = 0;

      await _isarService.isar.writeTxn(() async {
        if (allItems.isNotEmpty) {
          await _isarService.isar.queues.putAll(allItems);
        }
        await _isarService.isar.queues.put(queueItem);
      });

      Logger.info('📋 [QUEUE-DS] 插播成功, episodeId: ${episode.id}, position: 0, id: ${queueItem.id}, 更新了 ${allItems.length} 条后续记录');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 插播到队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('插播到队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 插播到队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('插播到队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> removeFromQueue(int id) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始从队列移除, id: $id');

      final item = await _isarService.isar.queues.get(id);

      if (item == null) {
        Logger.warning('📋 [QUEUE-DS] id: $id 不在队列中, 跳过移除');
        return;
      }

      final removedPosition = item.position;
      int updatedCount = 0;

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.queues.delete(id);

        final itemsToUpdate = await _isarService.isar.queues
            .where()
            .positionGreaterThan(removedPosition)
            .findAll();

        for (final item in itemsToUpdate) {
          item.position -= 1;
        }

        if (itemsToUpdate.isNotEmpty) {
          await _isarService.isar.queues.putAll(itemsToUpdate);
          updatedCount = itemsToUpdate.length;
        }
      });

      Logger.info('📋 [QUEUE-DS] 队列移除成功, id: $id, 原position: $removedPosition, 更新了 $updatedCount 条后续记录');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 从队列移除失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('从队列移除失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 从队列移除异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('从队列移除失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> removeFromQueueByEpisode(domain.Episode episode) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始根据 episode 从队列移除, episodeId: ${episode.id}');

      final item = await _findQueueByEpisode(episode);

      if (item == null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: ${episode.id} 不在队列中, 跳过移除');
        return;
      }

      Logger.info('📋 [QUEUE-DS] 找到队列记录, queueId: ${item.id}, position: ${item.position}, 开始移除');
      await removeFromQueue(item.id);

      Logger.info('📋 [QUEUE-DS] 根据 episode 移除队列成功, episodeId: ${episode.id}');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 episode 移除队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('根据 episode 移除队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 episode 移除队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('根据 episode 移除队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearQueue() async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始清空队列');

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.queues.clear();
      });

      Logger.info('📋 [QUEUE-DS] 队列清空成功');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 清空队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('清空队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 清空队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('清空队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> removeFromQueueByPodcastId(int podcastId, {String? podcastGuid, String? podcastITunesId}) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始根据 podcastId 从队列移除, podcastId: $podcastId, podcastITunesId: $podcastITunesId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
      
      final episodeIdsToRemove = episodes.map((e) => e.id).toSet();
      Logger.info('📋 [QUEUE-DS] 找到 ${episodeIdsToRemove.length} 个 episodes 需要清理');

      final allQueueItems = await _isarService.isar.queues.where().findAll();
      
      if (allQueueItems.isEmpty) {
        Logger.info('📋 [QUEUE-DS] 队列为空，无需清理');
        return;
      }

      final queueIdsToDelete = <int>[];
      for (final queueItem in allQueueItems) {
        if (podcastITunesId != null && podcastITunesId.isNotEmpty) {
          if (queueItem.podcastITunesId == podcastITunesId) {
            queueIdsToDelete.add(queueItem.id);
            Logger.info('📋 [QUEUE-DS] 标记删除队列记录: episodeId=${queueItem.episodeId}（podcastITunesId 匹配）');
            continue;
          }
        }

        if (podcastGuid != null && podcastGuid.isNotEmpty) {
          if (queueItem.podcastGuid == podcastGuid) {
            queueIdsToDelete.add(queueItem.id);
            Logger.info('📋 [QUEUE-DS] 标记删除队列记录: episodeId=${queueItem.episodeId}（podcastGuid 匹配）');
            continue;
          }
        }

        if (episodeIdsToRemove.contains(queueItem.episodeId)) {
          queueIdsToDelete.add(queueItem.id);
          Logger.info('📋 [QUEUE-DS] 标记删除队列记录: episodeId=${queueItem.episodeId}（podcastId 匹配）');
        } else {
          final episode = await _isarService.isar.episodes
              .where()
              .idEqualTo(queueItem.episodeId)
              .findFirst();
          if (episode == null) {
            queueIdsToDelete.add(queueItem.id);
            Logger.info('📋 [QUEUE-DS] 标记删除队列记录: episodeId=${queueItem.episodeId}（孤立记录）');
          }
        }
      }

      if (queueIdsToDelete.isEmpty) {
        Logger.info('📋 [QUEUE-DS] 没有需要删除的队列记录');
        return;
      }

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.queues.deleteAll(queueIdsToDelete);
      });

      Logger.info('📋 [QUEUE-DS] 根据 podcastId 移除队列完成, 共移除 ${queueIdsToDelete.length} 条记录');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 podcastId 移除队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('根据 podcastId 移除队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 podcastId 移除队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('根据 podcastId 移除队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<bool> isInQueue(domain.Episode episode) async {
    try {
      Logger.debug('📋 [QUEUE-DS] 检查是否在队列中, episodeId: ${episode.id}');

      final existing = await _findQueueByEpisode(episode);
      final result = existing != null;

      Logger.debug('📋 [QUEUE-DS] 队列检查结果, episodeId: ${episode.id}, isInQueue: $result');
      return result;
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 检查队列状态失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('检查队列状态失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 检查队列状态异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('检查队列状态失败', originalError: e, stackTrace: stackTrace);
    }
  }
}
