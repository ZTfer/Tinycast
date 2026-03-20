import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseNotifier<T> extends Notifier<AsyncValue<T>> {
  @override
  AsyncValue<T> build() => const AsyncValue.loading();

  void updateLoading() {
    state = const AsyncValue.loading();
  }

  void updateData(T data) {
    state = AsyncValue.data(data);
  }

  void updateError(Object error, [StackTrace? stackTrace]) {
    state = AsyncValue.error(error, stackTrace ?? StackTrace.empty);
  }

  Future<void> executeAsync(Future<T> Function() operation) async {
    updateLoading();
    try {
      final result = await operation();
      updateData(result);
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  void executeSync(T Function() operation) {
    try {
      final result = operation();
      updateData(result);
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  bool get isLoading => state.isLoading;

  bool get hasValue => state.hasValue;

  bool get hasError => state.hasError;

  T? get value => state.value;

  Object? get error => state.error;

  StackTrace? get stackTrace => state.stackTrace;
}

class BaseListNotifier<T> extends Notifier<AsyncValue<List<T>>> {
  @override
  AsyncValue<List<T>> build() => AsyncValue.data([]);

  void updateLoading() {
    state = const AsyncValue.loading();
  }

  void updateData(List<T> data) {
    state = AsyncValue.data(data);
  }

  void updateError(Object error, [StackTrace? stackTrace]) {
    state = AsyncValue.error(error, stackTrace ?? StackTrace.empty);
  }

  Future<void> executeAsync(Future<List<T>> Function() operation) async {
    updateLoading();
    try {
      final result = await operation();
      updateData(result);
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  void executeSync(List<T> Function() operation) {
    try {
      final result = operation();
      updateData(result);
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  void addItem(T item) {
    state.whenData((data) {
      updateData([...data, item]);
    });
  }

  void removeItem(bool Function(T) predicate) {
    state.whenData((data) {
      updateData(data.where((item) => !predicate(item)).toList());
    });
  }

  void updateItem(bool Function(T) predicate, T Function(T) update) {
    state.whenData((data) {
      updateData(
        data.map((item) => predicate(item) ? update(item) : item).toList(),
      );
    });
  }

  void clear() {
    updateData([]);
  }

  bool get isLoading => state.isLoading;

  bool get hasValue => state.hasValue;

  bool get hasError => state.hasError;

  List<T>? get value => state.value;

  Object? get error => state.error;

  StackTrace? get stackTrace => state.stackTrace;
}

class BasePaginatedNotifier<T> extends Notifier<AsyncValue<PaginatedData<T>>> {
  @override
  AsyncValue<PaginatedData<T>> build() =>
      const AsyncValue.data(PaginatedData(items: [], hasMore: true, page: 0));

  void updateLoading() {
    final currentValue = state.value;
    if (currentValue != null) {
      state = AsyncValue.data(currentValue.copyWith(isLoading: true));
    } else {
      state = const AsyncValue.loading();
    }
  }

  void updateData(List<T> items, {bool hasMore = true, int? page}) {
    state = AsyncValue.data(
      PaginatedData(
        items: items,
        hasMore: hasMore,
        page: page ?? state.value?.page ?? 0,
        isLoading: false,
      ),
    );
  }

  void updateError(Object error, [StackTrace? stackTrace]) {
    state = AsyncValue.error(error, stackTrace ?? StackTrace.empty);
  }

  Future<void> loadMore(Future<List<T>> Function(int page) operation) async {
    final currentPage = state.value?.page ?? 0;
    if (state.value?.isLoading ?? false || !(state.value?.hasMore ?? true)) {
      return;
    }

    updateLoading();
    try {
      final newItems = await operation(currentPage + 1);
      final currentItems = state.value?.items ?? [];
      updateData(
        [...currentItems, ...newItems],
        hasMore: newItems.isNotEmpty,
        page: currentPage + 1,
      );
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  Future<void> refresh(Future<List<T>> Function() operation) async {
    updateLoading();
    try {
      final items = await operation();
      updateData(items, hasMore: items.isNotEmpty, page: 0);
    } catch (error, stackTrace) {
      updateError(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(
      PaginatedData(items: [], hasMore: true, page: 0),
    );
  }

  bool get isLoading => state.value?.isLoading ?? false;

  bool get hasMore => state.value?.hasMore ?? true;

  List<T> get items => state.value?.items ?? [];

  int get page => state.value?.page ?? 0;
}

class PaginatedData<T> {
  final List<T> items;
  final bool hasMore;
  final int page;
  final bool isLoading;

  const PaginatedData({
    required this.items,
    required this.hasMore,
    required this.page,
    this.isLoading = false,
  });

  PaginatedData<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? page,
    bool? isLoading,
  }) {
    return PaginatedData<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
