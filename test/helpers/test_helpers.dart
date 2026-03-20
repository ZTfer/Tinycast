import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  static Future<void> pumpTestWidget(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
    Locale? locale,
    NavigatorObserver? navigatorObserver,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: locale,
        navigatorObservers: navigatorObserver != null
            ? [navigatorObserver]
            : const [],
        home: child,
      ),
    );
  }

  static Finder findWidgetWithText<T extends Widget>(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(T),
    );
  }

  static Finder findWidgetWithKey<T extends Widget>(String key) {
    return find.ancestor(
      of: find.byKey(Key(key)),
      matching: find.byType(T),
    );
  }

  static Future<void> pumpAndSettleWithDelay(
    WidgetTester tester, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    await tester.pumpAndSettle();
    await Future.delayed(delay);
    await tester.pumpAndSettle();
  }

  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  static void expectWidgetWithTextExists<T extends Widget>(String text) {
    expect(findWidgetWithText<T>(text), findsOneWidget);
  }

  static void expectWidgetWithTextNotExists<T extends Widget>(String text) {
    expect(findWidgetWithText<T>(text), findsNothing);
  }

  static void expectWidgetWithKeyExists<T extends Widget>(String key) {
    expect(findWidgetWithKey<T>(key), findsOneWidget);
  }

  static void expectWidgetWithKeyNotExists<T extends Widget>(String key) {
    expect(findWidgetWithKey<T>(key), findsNothing);
  }

  static Future<void> tapAndPump(
    WidgetTester tester,
    Finder finder, {
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    await tester.tap(finder);
    await tester.pump(pumpDuration);
  }

  static Future<void> enterTextAndPump(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    await tester.enterText(finder, text);
    await tester.pump(pumpDuration);
  }

  static Future<void> dragAndPump(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    await tester.drag(finder, offset);
    await tester.pump(pumpDuration);
  }

  static Future<void> longPressAndPump(
    WidgetTester tester,
    Finder finder, {
    Duration pumpDuration = const Duration(milliseconds: 500),
  }) async {
    await tester.longPress(finder);
    await tester.pump(pumpDuration);
  }

  static Widget wrapWithMaterialApp(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    );
  }

  static Widget wrapWithScaffold(Widget child) {
    return Scaffold(body: child);
  }

  static Widget wrapWithMediaQuery(
    Widget child, {
    Size size = const Size(375, 667),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    );
  }

  static Widget wrapWithDirectionality(
    Widget child, {
    TextDirection direction = TextDirection.ltr,
  }) {
    return Directionality(
      textDirection: direction,
      child: child,
    );
  }

  static Widget wrapWithAll(
    Widget child, {
    ThemeData? theme,
    Size size = const Size(375, 667),
    TextDirection direction = TextDirection.ltr,
  }) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  static void expectException<T extends Exception>(
    Future<void> Function() callback,
  ) async {
    try {
      await callback();
      fail('Expected exception of type $T but none was thrown');
    } catch (e) {
      expect(e, isA<T>());
    }
  }

  static void expectAsyncException<T extends Exception>(
    Future<void> Function() callback,
  ) async {
    try {
      await callback();
      fail('Expected async exception of type $T but none was thrown');
    } catch (e) {
      expect(e, isA<T>());
    }
  }

  static List<T> createList<T>(T Function() creator, int count) {
    return List.generate(count, (_) => creator());
  }

  static Map<String, T> createMap<T>(
    T Function(String key) creator,
    List<String> keys,
  ) {
    final result = <String, T>{};
    for (final key in keys) {
      result[key] = creator(key);
    }
    return result;
  }
}