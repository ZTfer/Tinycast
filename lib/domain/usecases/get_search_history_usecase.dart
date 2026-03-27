import '../entities/search_history.dart';
import '../repositories/search_history_repository.dart';

class GetSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  GetSearchHistoryUseCase(this._repository);

  Future<List<SearchHistory>> call() async {
    try {
      return await _repository.getSearchHistory();
    } catch (e) {
      throw Exception('Failed to get search history: $e');
    }
  }
}
