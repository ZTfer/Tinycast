import '../repositories/search_history_repository.dart';

class ClearSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  ClearSearchHistoryUseCase(this._repository);

  Future<void> call() async {
    try {
      return await _repository.clearSearchHistory();
    } catch (e) {
      throw Exception('Failed to clear search history: $e');
    }
  }
}
