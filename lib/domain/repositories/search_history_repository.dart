import 'package:tinycast/domain/entities/search_history.dart';

abstract class SearchHistoryRepository {
  Future<void> saveSearchHistory(String keyword);

  Future<List<SearchHistory>> getSearchHistory();

  Future<void> clearSearchHistory();
}
