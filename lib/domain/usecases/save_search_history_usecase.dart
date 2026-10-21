import 'package:tinycast/domain/repositories/search_history_repository.dart';

class SaveSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  SaveSearchHistoryUseCase(this._repository);

  Future<void> call(String keyword) async => _repository.saveSearchHistory(keyword);
}
