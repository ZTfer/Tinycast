import '../entities/search_history.dart';
import '../repositories/search_history_repository.dart';

class SaveSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  SaveSearchHistoryUseCase(this._repository);

  Future<void> call(String keyword) async {
    try {
      return await _repository.saveSearchHistory(keyword);
    } catch (e) {
      throw Exception('Failed to save search history: $e');
    }
  }
}
