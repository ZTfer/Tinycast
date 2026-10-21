import 'package:isar_community/isar.dart';
import 'package:tinycast/domain/entities/search_history.dart';
import 'package:tinycast/domain/repositories/search_history_repository.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/search_history_model.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  /// 搜索历史记录条数上限，超出时淘汰最旧条目
  static const int _maxHistoryCount = 50;

  @override
  Future<void> saveSearchHistory(String keyword) async {
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      final existing = await isar.searchHistoryModels
          .filter()
          .keywordEqualTo(keyword)
          .findFirst();

      if (existing != null) {
        existing.searchedAt = DateTime.now();
        await isar.searchHistoryModels.put(existing);
      } else {
        final newHistory = SearchHistoryModel()
          ..keyword = keyword
          ..searchedAt = DateTime.now();
        await isar.searchHistoryModels.put(newHistory);

        // 超出上限时删除最旧的记录
        final totalCount = await isar.searchHistoryModels.where().count();
        if (totalCount > _maxHistoryCount) {
          final oldest = await isar.searchHistoryModels
              .where()
              .sortBySearchedAt()
              .limit(totalCount - _maxHistoryCount)
              .findAll();
          await isar.searchHistoryModels.deleteAll(
            oldest.map((m) => m.id).toList(),
          );
        }
      }
    });
  }

  @override
  Future<List<SearchHistory>> getSearchHistory() async {
    final isar = IsarService.instance.isar;

    final models = await isar.searchHistoryModels
        .where()
        .sortBySearchedAtDesc()
        .findAll();

    return models
        .map((m) => SearchHistory(
              id: m.id,
              keyword: m.keyword,
              searchedAt: m.searchedAt,
            ))
        .toList();
  }

  @override
  Future<void> clearSearchHistory() async {
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      await isar.searchHistoryModels.clear();
    });
  }
}
