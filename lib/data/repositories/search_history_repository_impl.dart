import 'package:isar_community/isar.dart';
import '../../domain/entities/search_history.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../database/isar_service.dart';
import '../models/search_history_model.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
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
      }
    });
  }

  @override
  Future<List<SearchHistory>> getSearchHistory() async {
    final isar = IsarService.instance.isar;

    final models = await isar.searchHistoryModels
        .filter()
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
      await isar.searchHistoryModels.filter().deleteAll();
    });
  }
}
