import 'package:isar_community/isar.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../database/isar_service.dart';
import '../models/queue_model.dart';

class LocalQueueDataSource {
  final IsarService _isarService;

  LocalQueueDataSource({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

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

  Future<void> addToQueue(int episodeId) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始添加到队列, episodeId: $episodeId');

      final existing = await _isarService.isar.queues
          .where()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      if (existing != null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: $episodeId 已存在于队列中, 跳过添加');
        return;
      }

      Queue? queueItem;

      await _isarService.isar.writeTxn(() async {
        final allItems = await _isarService.isar.queues.where().findAll();
        final maxPosition = allItems.isEmpty ? 0 : allItems.map((e) => e.position).reduce((a, b) => a > b ? a : b);

        queueItem = Queue()
          ..episodeId = episodeId
          ..position = maxPosition + 1;

        await _isarService.isar.queues.put(queueItem!);
      });

      Logger.info('📋 [QUEUE-DS] 队列添加成功, episodeId: $episodeId, position: ${queueItem?.position}, id: ${queueItem?.id}');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 添加到队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('添加到队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 添加到队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('添加到队列失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> insertToQueueFront(int episodeId) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始插播到队列最前, episodeId: $episodeId');

      final existing = await _isarService.isar.queues
          .where()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      if (existing != null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: $episodeId 已存在于队列中, 先移除再插播');
        await removeFromQueue(existing.id);
      }

      final allItems = await _isarService.isar.queues.where().findAll();

      for (final item in allItems) {
        item.position += 1;
      }

      final queueItem = Queue()
        ..episodeId = episodeId
        ..position = 0;

      await _isarService.isar.writeTxn(() async {
        if (allItems.isNotEmpty) {
          await _isarService.isar.queues.putAll(allItems);
        }
        await _isarService.isar.queues.put(queueItem);
      });

      Logger.info('📋 [QUEUE-DS] 插播成功, episodeId: $episodeId, position: 0, id: ${queueItem.id}, 更新了 ${allItems.length} 条后续记录');
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

  Future<void> removeFromQueueByEpisodeId(int episodeId) async {
    try {
      Logger.info('📋 [QUEUE-DS] 开始根据 episodeId 从队列移除, episodeId: $episodeId');

      final item = await _isarService.isar.queues
          .where()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      if (item == null) {
        Logger.warning('📋 [QUEUE-DS] episodeId: $episodeId 不在队列中, 跳过移除');
        return;
      }

      Logger.info('📋 [QUEUE-DS] 找到队列记录, queueId: ${item.id}, position: ${item.position}, 开始移除');
      await removeFromQueue(item.id);

      Logger.info('📋 [QUEUE-DS] 根据 episodeId 移除队列成功, episodeId: $episodeId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 episodeId 移除队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('根据 episodeId 移除队列失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-DS] 根据 episodeId 移除队列异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('根据 episodeId 移除队列失败', originalError: e, stackTrace: stackTrace);
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

  Future<bool> isInQueue(int episodeId) async {
    try {
      Logger.debug('📋 [QUEUE-DS] 检查是否在队列中, episodeId: $episodeId');

      final count = await _isarService.isar.queues
          .where()
          .episodeIdEqualTo(episodeId)
          .count();

      final result = count > 0;
      Logger.debug('📋 [QUEUE-DS] 队列检查结果, episodeId: $episodeId, isInQueue: $result, count: $count');
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
