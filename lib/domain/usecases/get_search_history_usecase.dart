import 'package:tinycast/domain/entities/search_history.dart';
import 'package:tinycast/domain/repositories/search_history_repository.dart';

class GetSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  GetSearchHistoryUseCase(this._repository);

  Future<List<SearchHistory>> call() async => _repository.getSearchHistory();
}
