import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';

@GenerateMocks([])
class MockFactory {
  static Mock createMock() {
    return Mock();
  }

  static void setupMock<T extends Mock>(
    T mock,
    void Function(T) setup,
  ) {
    setup(mock);
  }

  static void whenThenReturn<T>(
    T mock,
    dynamic method,
    T returnValue,
  ) {
    when(method).thenReturn(returnValue);
  }

  static void whenThenThrow<T>(
    T mock,
    dynamic method,
    Exception exception,
  ) {
    when(method).thenThrow(exception);
  }

  static void whenThenAnswer<T>(
    T mock,
    dynamic method,
    Answering<dynamic> answer,
  ) {
    when(method).thenAnswer(answer);
  }

  static void whenThenAsync<T>(
    T mock,
    dynamic method,
    Future<T> futureValue,
  ) {
    when(method).thenAnswer((_) async => await futureValue);
  }

  static void verifyCalled<T>(
    T mock,
    dynamic method, {
    int called = 1,
  }) {
    verify(method).called(called);
  }

  static void verifyNeverCalled<T>(
    T mock,
    dynamic method,
  ) {
    verifyNever(method);
  }

  static void verifyCalledAtLeastOnce<T>(
    T mock,
    dynamic method,
  ) {
    verify(method).called(greaterThanOrEqualTo(1));
  }

  static void verifyCalledAtLeast<T>(
    T mock,
    dynamic method,
    int count,
  ) {
    verify(method).called(greaterThanOrEqualTo(count));
  }

  static void verifyCalledAtMost<T>(
    T mock,
    dynamic method,
    int count,
  ) {
    verify(method).called(lessThanOrEqualTo(count));
  }

  static void verifyCalledExactly<T>(
    T mock,
    dynamic method,
    int count,
  ) {
    verify(method).called(count);
  }

  static void resetMock<T extends Mock>(T mock) {
    reset(mock);
  }

  static void clearInteractions<T extends Mock>(T mock) {
    clearInteractions(mock);
  }

  static void verifyNoMoreInteractions<T extends Mock>(T mock) {
    verifyNoMoreInteractions(mock);
  }

  static void verifyZeroInteractions<T extends Mock>(T mock) {
    verifyZeroInteractions(mock);
  }

  static List<dynamic> captureArgs<T>(
    T mock,
    dynamic method,
  ) {
    return verify(method).captured;
  }

  static List<dynamic> getCapturedArgs<T>(
    T mock,
    dynamic method,
  ) {
    return verify(method).captured;
  }

  static dynamic getFirstCapturedArg<T>(
    T mock,
    dynamic method,
  ) {
    return verify(method).captured.first;
  }

  static dynamic getLastCapturedArg<T>(
    T mock,
    dynamic method,
  ) {
    return verify(method).captured.last;
  }

  static dynamic getCapturedArgAt<T>(
    T mock,
    dynamic method,
    int index,
  ) {
    return verify(method).captured[index];
  }

  static void stubWithDefaultValue<T extends Mock>(
    T mock,
    dynamic method,
    dynamic defaultValue,
  ) {
    when(method).thenReturn(defaultValue);
  }

  static void stubWithException<T extends Mock>(
    T mock,
    dynamic method,
    Exception exception,
  ) {
    when(method).thenThrow(exception);
  }

  static void stubWithAsyncValue<T extends Mock>(
    T mock,
    dynamic method,
    Future<dynamic> futureValue,
  ) {
    when(method).thenAnswer((_) async => await futureValue);
  }

  static void stubWithCallback<T extends Mock>(
    T mock,
    dynamic method,
    Function callback,
  ) {
    when(method).thenAnswer((invocation) => callback(invocation.positionalArguments));
  }

  static void stubWithStream<T extends Mock>(
    T mock,
    dynamic method,
    Stream<dynamic> stream,
  ) {
    when(method).thenAnswer((_) => stream);
  }

  static void stubWithIterable<T extends Mock>(
    T mock,
    dynamic method,
    Iterable<dynamic> iterable,
  ) {
    when(method).thenAnswer((_) => Stream.fromIterable(iterable));
  }

  static void stubWithError<T extends Mock>(
    T mock,
    dynamic method,
    Error error,
  ) {
    when(method).thenThrow(error);
  }

  static void stubWithAsyncError<T extends Mock>(
    T mock,
    dynamic method,
    Future<Error> futureError,
  ) {
    when(method).thenAnswer((_) async => throw await futureError);
  }

  static void stubWithFutureError<T extends Mock>(
    T mock,
    dynamic method,
    Error error,
  ) {
    when(method).thenAnswer((_) => Future.error(error));
  }

  static void stubWithDelayedValue<T extends Mock>(
    T mock,
    dynamic method,
    dynamic value,
    Duration delay,
  ) {
    when(method).thenAnswer((_) async {
      await Future.delayed(delay);
      return value;
    });
  }

  static void stubWithDelayedError<T extends Mock>(
    T mock,
    dynamic method,
    Error error,
    Duration delay,
  ) {
    when(method).thenAnswer((_) async {
      await Future.delayed(delay);
      throw error;
    });
  }

  static void stubWithConsecutiveValues<T extends Mock>(
    T mock,
    dynamic method,
    List<dynamic> values,
  ) {
    when(method).thenAnswer((_) => values.removeAt(0));
  }

  static void stubWithConsecutiveExceptions<T extends Mock>(
    T mock,
    dynamic method,
    List<Exception> exceptions,
  ) {
    when(method).thenAnswer((_) => throw exceptions.removeAt(0));
  }

  static void stubWithConsecutiveAsyncValues<T extends Mock>(
    T mock,
    dynamic method,
    List<Future<dynamic>> futures,
  ) {
    when(method).thenAnswer((_) async => await futures.removeAt(0));
  }

  static void stubWithConsecutiveAsyncExceptions<T extends Mock>(
    T mock,
    dynamic method,
    List<Future<Exception>> futures,
  ) {
    when(method).thenAnswer((_) async => throw await futures.removeAt(0));
  }

  static void stubWithIterableValues<T extends Mock>(
    T mock,
    dynamic method,
    Iterable<dynamic> values,
  ) {
    when(method).thenAnswer((_) => values.iterator.current);
  }

  static void stubWithIterableExceptions<T extends Mock>(
    T mock,
    dynamic method,
    Iterable<Exception> exceptions,
  ) {
    when(method).thenAnswer((_) => throw exceptions.iterator.current);
  }

  static void stubWithIterableAsyncValues<T extends Mock>(
    T mock,
    dynamic method,
    Iterable<Future<dynamic>> futures,
  ) {
    when(method).thenAnswer((_) async => await futures.iterator.current);
  }

  static void stubWithIterableAsyncExceptions<T extends Mock>(
    T mock,
    dynamic method,
    Iterable<Future<Exception>> futures,
  ) {
    when(method).thenAnswer((_) async => throw await futures.iterator.current);
  }

  static void stubWithGenerator<T extends Mock>(
    T mock,
    dynamic method,
    dynamic Function() generator,
  ) {
    when(method).thenAnswer((_) => generator());
  }

  static void stubWithAsyncGenerator<T extends Mock>(
    T mock,
    dynamic method,
    Future<dynamic> Function() generator,
  ) {
    when(method).thenAnswer((_) async => await generator());
  }

  static void stubWithGeneratorAndArgs<T extends Mock>(
    T mock,
    dynamic method,
    dynamic Function(List<dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) => generator(invocation.positionalArguments));
  }

  static void stubWithAsyncGeneratorAndArgs<T extends Mock>(
    T mock,
    dynamic method,
    Future<dynamic> Function(List<dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) async => await generator(invocation.positionalArguments));
  }

  static void stubWithGeneratorAndNamedArgs<T extends Mock>(
    T mock,
    dynamic method,
    dynamic Function(Map<String, dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) => generator(
      Map.fromEntries(
        invocation.namedArguments.entries.map(
          (e) => MapEntry(e.key.toString().replaceAll('Symbol(', '').replaceAll(')', ''), e.value),
        ),
      ),
    ));
  }

  static void stubWithAsyncGeneratorAndNamedArgs<T extends Mock>(
    T mock,
    dynamic method,
    Future<dynamic> Function(Map<String, dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) async => await generator(
      Map.fromEntries(
        invocation.namedArguments.entries.map(
          (e) => MapEntry(e.key.toString().replaceAll('Symbol(', '').replaceAll(')', ''), e.value),
        ),
      ),
    ));
  }

  static void stubWithGeneratorAndAllArgs<T extends Mock>(
    T mock,
    dynamic method,
    dynamic Function(List<dynamic>, Map<String, dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) => generator(
      invocation.positionalArguments,
      Map.fromEntries(
        invocation.namedArguments.entries.map(
          (e) => MapEntry(e.key.toString().replaceAll('Symbol(', '').replaceAll(')', ''), e.value),
        ),
      ),
    ));
  }

  static void stubWithAsyncGeneratorAndAllArgs<T extends Mock>(
    T mock,
    dynamic method,
    Future<dynamic> Function(List<dynamic>, Map<String, dynamic>) generator,
  ) {
    when(method).thenAnswer((invocation) async => await generator(
      invocation.positionalArguments,
      Map.fromEntries(
        invocation.namedArguments.entries.map(
          (e) => MapEntry(e.key.toString().replaceAll('Symbol(', '').replaceAll(')', ''), e.value),
        ),
      ),
    ));
  }
}