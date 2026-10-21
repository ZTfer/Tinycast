import 'package:tinycast/domain/repositories/search_history_repository.dart';

class ClearSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  ClearSearchHistoryUseCase(this._repository);

  Future<void> call() async => _repository.clearSearchHistory();
}
