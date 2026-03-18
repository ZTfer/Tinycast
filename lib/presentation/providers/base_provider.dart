import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProviderBuilder<T> = T Function();

typedef AsyncProviderBuilder<T> = Future<T> Function();

typedef StreamProviderBuilder<T> = Stream<T> Function();

typedef ProviderFamilyBuilder<T, A> = T Function(A arg);

typedef AsyncProviderFamilyBuilder<T, A> = Future<T> Function(A arg);

typedef StreamProviderFamilyBuilder<T, A> = Stream<T> Function(A arg);

class BaseProvider {
  static Provider<T> create<T>(ProviderBuilder<T> builder) {
    return Provider<T>((ref) => builder());
  }

  static FutureProvider<T> createAsync<T>(AsyncProviderBuilder<T> builder) {
    return FutureProvider<T>((ref) async {
      return await builder();
    });
  }

  static StreamProvider<T> createStream<T>(StreamProviderBuilder<T> builder) {
    return StreamProvider<T>((ref) => builder());
  }

  static Provider<T> createLazy<T>(ProviderBuilder<T> builder) {
    return Provider<T>((ref) => builder());
  }

  static StateNotifierProvider<T, S> createNotifier<T extends StateNotifier<S>, S>(
    T Function() builder,
  ) {
    return StateNotifierProvider<T, S>((ref) => builder());
  }

  static ChangeNotifierProvider<T> createChangeNotifier<T extends ChangeNotifier>(
    T Function() builder,
  ) {
    return ChangeNotifierProvider<T>((ref) => builder());
  }

  static ProviderFamily<T, A> createFamily<T, A>(
    ProviderFamilyBuilder<T, A> builder,
  ) {
    return ProviderFamily<T, A>((ref, arg) => builder(arg));
  }

  static FutureProviderFamily<T, A> createAsyncFamily<T, A>(
    AsyncProviderFamilyBuilder<T, A> builder,
  ) {
    return FutureProviderFamily<T, A>((ref, arg) async {
      return await builder(arg);
    });
  }

  static StreamProviderFamily<T, A> createStreamFamily<T, A>(
    StreamProviderFamilyBuilder<T, A> builder,
  ) {
    return StreamProviderFamily<T, A>((ref, arg) => builder(arg));
  }

  static StateNotifierProviderFamily<T, S, A> createNotifierFamily<T extends StateNotifier<S>, S, A>(
    T Function(A) builder,
  ) {
    return StateNotifierProviderFamily<T, S, A>((ref, arg) => builder(arg));
  }

  static AutoDisposeProvider<T> createAutoDispose<T>(ProviderBuilder<T> builder) {
    return AutoDisposeProvider<T>((ref) => builder());
  }

  static AutoDisposeFutureProvider<T> createAutoDisposeAsync<T>(
    AsyncProviderBuilder<T> builder,
  ) {
    return AutoDisposeFutureProvider<T>((ref) async {
      return await builder();
    });
  }

  static AutoDisposeStreamProvider<T> createAutoDisposeStream<T>(
    StreamProviderBuilder<T> builder,
  ) {
    return AutoDisposeStreamProvider<T>((ref) => builder());
  }

  static AutoDisposeStateNotifierProvider<T, S> createAutoDisposeNotifier<T extends StateNotifier<S>, S>(
    T Function() builder,
  ) {
    return AutoDisposeStateNotifierProvider<T, S>((ref) => builder());
  }

  static AutoDisposeProviderFamily<T, A> createAutoDisposeFamily<T, A>(
    ProviderFamilyBuilder<T, A> builder,
  ) {
    return AutoDisposeProviderFamily<T, A>((ref, arg) => builder(arg));
  }

  static AutoDisposeFutureProviderFamily<T, A> createAutoDisposeAsyncFamily<T, A>(
    AsyncProviderFamilyBuilder<T, A> builder,
  ) {
    return AutoDisposeFutureProviderFamily<T, A>((ref, arg) async {
      return await builder(arg);
    });
  }

  static AutoDisposeStreamProviderFamily<T, A> createAutoDisposeStreamFamily<T, A>(
    StreamProviderFamilyBuilder<T, A> builder,
  ) {
    return AutoDisposeStreamProviderFamily<T, A>((ref, arg) => builder(arg));
  }

  static AutoDisposeStateNotifierProviderFamily<T, S, A> createAutoDisposeNotifierFamily<T extends StateNotifier<S>, S, A>(
    T Function(A) builder,
  ) {
    return AutoDisposeStateNotifierProviderFamily<T, S, A>((ref, arg) => builder(arg));
  }
}
