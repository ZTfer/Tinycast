import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/pages/homepage.dart';
import 'package:tinycast/multi_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/router/app_router.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = parseArguments(windowController.arguments);

  switch (arguments.type) {
    case 'main':
      await initMainWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: MyApp()));
      break;
    case 'settings':
      await initSettingsWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: SettingsWindowApp()));
      break;
    case 'subscribe':
      await initSubscribeWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: SubscribeWindowApp()));
      break;
    default:
      await initMainWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: MyApp()));
  }
}

Future<void> _initializeApp() async {
  await IsarService.instance.open();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinycast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
      home: const MyHomePage(),
    );
  }
}
