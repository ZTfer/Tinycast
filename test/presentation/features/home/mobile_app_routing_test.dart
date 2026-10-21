import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/main.dart';

void main() {
  Future<WidgetsApp> pumpMobileApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp(home: SizedBox())),
    );
    return tester.widget<WidgetsApp>(find.byType(WidgetsApp));
  }

  testWidgets('MyApp 提供命名路由生成器', (tester) async {
    final app = await pumpMobileApp(tester);

    expect(app.onGenerateRoute, isNotNull);

    final route = app.onGenerateRoute!(
      const RouteSettings(name: AppRoutes.subscribe),
    );
    expect(route, isNotNull);
  });

  testWidgets('MyApp 提供 Material 本地化代理', (tester) async {
    final app = await pumpMobileApp(tester);

    expect(
      app.localizationsDelegates,
      contains(GlobalMaterialLocalizations.delegate),
    );
  });
}
