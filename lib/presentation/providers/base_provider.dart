import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProviderBuilder<T> = T Function();

typedef AsyncProviderBuilder<T> = Future<T> Function();

typedef StreamProviderBuilder<T> = Stream<T> Function();

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
}
