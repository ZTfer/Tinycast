import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/search_history.dart';
import 'package:tinycast/domain/entities/search_result.dart';
import 'package:tinycast/domain/repositories/search_history_repository.dart';
import 'package:tinycast/domain/usecases/clear_search_history_usecase.dart';
import 'package:tinycast/domain/usecases/get_search_history_usecase.dart';
import 'package:tinycast/domain/usecases/save_search_history_usecase.dart';
import 'package:tinycast/domain/usecases/search_local_content_usecase.dart';
import 'package:tinycast/data/repositories/search_history_repository_impl.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

enum SearchStatus { initial, history, results, empty }

class NavigationTarget {
  final String route;
  final Object? arguments;

  const NavigationTarget(this.route, {this.arguments});
}

class SearchState {
  final SearchStatus status;
  final List<SearchHistory> searchHistory;
  final SearchResult? searchResult;
  final int selectedIndex;
  final String searchKeyword;
  final bool isLoading;

  SearchState({
    this.status = SearchStatus.initial,
    this.searchHistory = const [],
    this.searchResult,
    this.selectedIndex = 0,
    this.searchKeyword = '',
    this.isLoading = false,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<SearchHistory>? searchHistory,
    SearchResult? searchResult,
    int? selectedIndex,
    String? searchKeyword,
    bool? isLoading,
  }) {
    return SearchState(
      status: status ?? this.status,
      searchHistory: searchHistory ?? this.searchHistory,
      searchResult: searchResult ?? this.searchResult,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepositoryImpl();
});

final saveSearchHistoryUseCaseProvider = Provider<SaveSearchHistoryUseCase>((ref) {
  final repository = ref.watch(searchHistoryRepositoryProvider);
  return SaveSearchHistoryUseCase(repository);
});

final getSearchHistoryUseCaseProvider = Provider<GetSearchHistoryUseCase>((ref) {
  final repository = ref.watch(searchHistoryRepositoryProvider);
  return GetSearchHistoryUseCase(repository);
});

final clearSearchHistoryUseCaseProvider = Provider<ClearSearchHistoryUseCase>((ref) {
  final repository = ref.watch(searchHistoryRepositoryProvider);
  return ClearSearchHistoryUseCase(repository);
});

final searchLocalContentUseCaseProvider = Provider<SearchLocalContentUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return SearchLocalContentUseCase(repository);
});

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    Future.microtask(() => loadSearchHistory());
    return SearchState();
  }

  SaveSearchHistoryUseCase get _saveSearchHistoryUseCase =>
      ref.read(saveSearchHistoryUseCaseProvider);
  GetSearchHistoryUseCase get _getSearchHistoryUseCase =>
      ref.read(getSearchHistoryUseCaseProvider);
  ClearSearchHistoryUseCase get _clearSearchHistoryUseCase =>
      ref.read(clearSearchHistoryUseCaseProvider);
  SearchLocalContentUseCase get _searchLocalContentUseCase =>
      ref.read(searchLocalContentUseCaseProvider);

  Future<void> loadSearchHistory() async {
    try {
      final history = await _getSearchHistoryUseCase();
      state = state.copyWith(
        searchHistory: history,
        status: history.isEmpty ? SearchStatus.initial : SearchStatus.history,
        selectedIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        searchHistory: [],
        status: SearchStatus.initial,
      );
    }
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      await loadSearchHistory();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchKeyword: keyword,
      selectedIndex: 0,
    );

    try {
      await _saveSearchHistoryUseCase(keyword);
      final result = await _searchLocalContentUseCase(keyword);
      final history = await _getSearchHistoryUseCase();

      state = state.copyWith(
        status: result.isEmpty ? SearchStatus.empty : SearchStatus.results,
        searchResult: result,
        searchHistory: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.empty,
        searchResult: null,
        isLoading: false,
      );
    }
  }

  Future<void> clearHistory() async {
    try {
      await _clearSearchHistoryUseCase();
      state = state.copyWith(
        searchHistory: [],
        status: SearchStatus.initial,
        selectedIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        searchHistory: [],
        status: SearchStatus.initial,
      );
    }
  }

  void selectNext() {
    final total = totalItemCount;
    if (total == 0) return;

    final newIndex = state.selectedIndex < total - 1
        ? state.selectedIndex + 1
        : 0;
    state = state.copyWith(selectedIndex: newIndex);
  }

  void selectPrevious() {
    final total = totalItemCount;
    if (total == 0) return;

    final newIndex = state.selectedIndex > 0
        ? state.selectedIndex - 1
        : total - 1;
    state = state.copyWith(selectedIndex: newIndex);
  }

  NavigationTarget? confirmSelection() {
    if (state.selectedIndex < 0 || state.selectedIndex >= totalItemCount) return null;

    if (state.status == SearchStatus.history) {
      final history = state.searchHistory;
      if (state.selectedIndex < history.length) {
        final keyword = history[state.selectedIndex].keyword;
        search(keyword);
      }
      return null;
    }

    if (state.status == SearchStatus.results && state.searchResult != null) {
      final podcasts = state.searchResult!.podcasts;
      final episodes = state.searchResult!.episodes;
      final podcastsCount = podcasts.length;

      if (state.selectedIndex < podcastsCount) {
        final podcast = podcasts[state.selectedIndex];
        return NavigationTarget(
          AppRoutes.podcastDetail,
          arguments: podcast.id,
        );
      } else {
        final episodeIndex = state.selectedIndex - podcastsCount;
        if (episodeIndex < episodes.length) {
          final episode = episodes[episodeIndex];
          return NavigationTarget(
            AppRoutes.episodeDetail,
            arguments: episode,
          );
        }
      }
    }
    return null;
  }

  void setSelectedIndex(int index) {
    if (index >= 0 && index < totalItemCount) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  Future<void> resetToHistory() async {
    try {
      final history = await _getSearchHistoryUseCase();
      state = state.copyWith(
        searchHistory: history,
        status: history.isEmpty ? SearchStatus.initial : SearchStatus.history,
        selectedIndex: 0,
        searchKeyword: '',
        searchResult: null,
      );
    } catch (e) {
      state = state.copyWith(
        searchHistory: [],
        status: SearchStatus.initial,
        searchKeyword: '',
        searchResult: null,
      );
    }
  }

  int get totalItemCount {
    switch (state.status) {
      case SearchStatus.history:
        return state.searchHistory.length;
      case SearchStatus.results:
        if (state.searchResult == null) return 0;
        return state.searchResult!.podcasts.length +
            state.searchResult!.episodes.length;
      case SearchStatus.initial:
      case SearchStatus.empty:
        return 0;
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

final searchStateProvider = Provider<SearchState>((ref) {
  return ref.watch(searchProvider);
});

final searchHistoryProvider = Provider<List<SearchHistory>>((ref) {
  return ref.watch(searchProvider).searchHistory;
});

final searchResultsProvider = Provider<SearchResult?>((ref) {
  return ref.watch(searchProvider).searchResult;
});

final selectedIndexProvider = Provider<int>((ref) {
  return ref.watch(searchProvider).selectedIndex;
});

final showToolbarProvider = Provider<bool>((ref) {
  final status = ref.watch(searchProvider).status;
  return status == SearchStatus.history || status == SearchStatus.results;
});
