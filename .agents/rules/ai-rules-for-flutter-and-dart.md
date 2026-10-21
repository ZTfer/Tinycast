# Flutter AI Rules
**Role:** Expert Dev. Premium, beautiful code.
**Tools:** `dart_format`, `dart_fix`, `analyze_files`.
**Stack:**
* **Nav:** 自定义 AppRouter
* **State:** Riverpod
* **Data:** Isar 数据库
* **UI:** 自定义设计系统（避免 Material Design）
* **Json:** `json_serializable` (snake_case).
**Code:**
* **SOLID**.
* **Layers:** Pres/Domain/Data.
* **Naming:** PascalTypes, camelMembers, snake_files.
* **Async:** `async/await`, try-catch.
* **Log:** 统一走 `Logger` 门面（`lib/core/utils/logger.dart`），禁用 `print` 与 `dart:developer`。
* **Null:** Sound safety。`!` 仅限非空可局部证明处（详见 Null Safety 条目）。
**Perf:**
* `const` everywhere.
* `ListView.builder`.
* `compute()` for heavy tasks.
**Testing:** `flutter test`, `integration_test`.
**A11y:** 4.5:1 contrast, Semantics.
**Design:** "Wow" factor. Glassmorphism, shadows.
**Docs:** Public API `///`. Explain "Why".

---
trigger: always_on
---

# AI Rules for Flutter

You are an expert Flutter and Dart developer. Your goal is to build beautiful, performant, and maintainable applications following modern best practices—**without relying on Material Design**. Use custom design systems and Flutter's core widgets to create unique, platform-agnostic user interfaces.

## Interaction Guidelines
* **User Persona:** Assume the user is familiar with programming concepts but may be new to Dart.
* **Explanations:** When generating code, provide explanations for Dart-specific features like null safety, futures, and streams.
* **Clarification:** If a request is ambiguous, ask for clarification on the intended functionality and the target platform (e.g., command-line, web, server).
* **Dependencies:** When suggesting new dependencies from `pub.dev`, explain their benefits. Use `pub_dev_search` if available.
* **Formatting:** ALWAYS use the `dart_format` tool to ensure consistent code formatting.
* **Fixes:** Use the `dart_fix` tool to automatically fix many common errors.
* **Linting:** Use the Dart linter with `flutter_lints` to catch common issues.

## Flutter Style Guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code. Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially `StatelessWidget`) should be immutable.
* **State Management:** Separate ephemeral state and app state. Use Riverpod for app state management.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose complex UIs from smaller, reusable widgets.

## Package Management
* **Pub Tool:** Use `pub` or `flutter pub add`.
* **Dev Dependencies:** Use `flutter pub add dev:<package>`.
* **Overrides:** Use `flutter pub add override:<package>:<version>`.
* **Removal:** `dart pub remove <package>`.

## Code Quality
* **Structure:** Adhere to maintainable code structure and separation of concerns.
* **Naming:** Avoid abbreviations. Use `PascalCase` (classes), `camelCase` (members), `snake_case` (files).
* **Conciseness:** Functions should be short (<20 lines) and single-purpose.
* **Error Handling:** Anticipate and handle potential errors. Don't let code fail silently.
* **Logging:** 统一使用项目 `Logger` 门面（`Logger.debug/info/warning/error`，`lib/core/utils/logger.dart`）。Debug / Profile 默认保留 `info` 及以上，Release 默认保留 `warning` 及以上；`Logger.debug` 默认被过滤，需显式调用 `Logger.setMinLevel(LogLevel.debug)`。控制台输出仅在 `kDebugMode` 下经 `debugPrint`；调用 `initFileLogging()` 后会追加写入应用支持目录下按日期命名的文件。禁止使用 `print`，也不直接使用 `dart:developer`。

## Dart Best Practices
* **Effective Dart:** Follow official guidelines.
* **Async/Await:** Use `Future`, `async`, `await` for operations. Use `Stream` for events.
* **Null Safety:** Write soundly null-safe code. `!` 断言仅在非空性可局部证明时允许：经 null 检查后的同一作用域内、`assert` 保证的 widget 字段、框架保证非空的返回值（如 `ModalRoute.of(context)!.settings`）。禁止对跨异步边界或跨状态存活的可空字段使用 `!`。优先迁移口径：`??` 提供默认值、`?.` 空感知调用、`final local = x; if (local != null) ...` 局部提升，或将参数改为 `required` 非空。
* **Pattern Matching:** Use switch expressions and pattern matching.
* **Records:** Use records for multiple return values.
* **Exception Handling:** Use custom exceptions for specific situations.
* **Arrow Functions:** Use `=>` for one-line functions.

## Flutter Best Practices
* **Immutability:** Widgets are immutable. Rebuild, don't mutate.
* **Composition:** Compose smaller private widgets (`class MyWidget extends StatelessWidget`) over helper methods.
* **Lists:** Use `ListView.builder` or `SliverList` for performance.
* **Isolates:** Use `compute()` for expensive calculations (JSON parsing) to avoid UI blocking.
* **Const:** Use `const` constructors everywhere possible to reduce rebuilds.
* **Build Methods:** Avoid expensive ops (network) in `build()`.

## State Management
* **Primary Solution:** Use Riverpod for state management.
* **Provider Scope:** Always wrap the app with `ProviderScope`.
* **Widget Ref:** Use `WidgetRef` for accessing providers in widgets.
* **State Notifiers:** 使用 Riverpod 3 的 `Notifier` / `AsyncNotifier` 及其对应
  `NotifierProvider` / `AsyncNotifierProvider`；不要新增 `StateNotifier`。

```dart
// Riverpod 3 Notifier 示例
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

// In widget
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

## Routing (Custom AppRouter)
Use the project's custom `AppRouter` for all navigation needs. Follow the existing pattern for adding new routes.

```dart
// Navigation example
AppRouter.navigateTo(context, AppRoutes.podcastDetail, arguments: podcast.id);
```

## Data Handling & Serialization
* **Database:** Use Isar database for local storage.
* **JSON:** Use `json_serializable` and `json_annotation` for API data.
* **Naming:** Use `fieldRename: FieldRename.snake` for consistency.

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;
  User({required this.firstName, required this.lastName});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Visual Design & Theming (Custom / Non-Material)
* **Visual Design:** Build beautiful and intuitive user interfaces using **custom design systems**, not tied to any specific design language.
* **Typography:** Define your own typography scale using `TextStyle` and `DefaultTextStyle`. Avoid reliance on `TextTheme`.
* **Color System:** Define a consistent color palette using constants or a dedicated `AppColors` class. Avoid `ColorScheme`.
* **Shadows & Depth:** Use `BoxShadow` manually where needed for depth; avoid assumptions about elevation.
* **Icons:** 项目同时使用 Material Icons（`uses-material-design: true`）和
  Lucide Icons（`lucide_icons_flutter`）。新增图标时优先沿用当前页面已有的图标集，
  不要混入第三套图标库；不确定图标名是否存在时先查依赖源码或编译验证。
* **Theming:** If theming is needed, implement it via inherited widgets or global config objects—not `ThemeData`.

**Do not use**: `MaterialApp`, `ThemeData`, `MaterialColor`, `useMaterial3`, `ColorScheme.fromSeed`, or `GoogleFonts.outfitTextTheme()`.

## Layout Best Practices
* **Core Layout Widgets:** Use `Container`, `Row`, `Column`, `Stack`, `Positioned`, `Expanded`, `Flexible` for layout.
* **Scrolling:** Use `SingleChildScrollView` for fixed-size content, `ListView.builder` for long lists.
* **Responsive Design:** Use `LayoutBuilder` for responsive layouts based on available space.
* **Overlays:** Use `Overlay` or `OverlayPortal` for dropdowns, tooltips, and other floating UI elements.
* **Interaction:** Use `GestureDetector`, `MouseRegion` for user interactions.

## Custom Widgets
* **Build Custom Components:** Create custom widgets for UI elements instead of using Material Design components.
* **Reusability:** Design widgets to be reusable across the app.
* **Consistency:** Maintain consistent design language across all custom widgets.

```dart
// Custom Button Example
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  
  const CustomButton({super.key, required this.text, required this.onPressed});
  
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFE0E0E0) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}
```

## Documentation Philosophy
* **Comment wisely:** Use comments to explain why the code is written a certain way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the reader in mind. If you had a question and found the answer, add it to the documentation where you first looked.
* **No useless documentation:** If the documentation only restates the obvious from the code's name, it's not helpful.
* **Consistency is key:** Use consistent terminology throughout your documentation.
* **Use `///` for doc comments:** This allows documentation generation tools to pick them up.
* **Start with a single-sentence summary:** The first sentence should be a concise, user-centric summary ending with a period.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's context, like the class name or signature.
* **Public APIs are a priority:** Always document public APIs.

## Accessibility
* **Contrast:** Ensure text has a contrast ratio of at least **4.5:1** against its background.
* **Dynamic Text Scaling:** Test your UI to ensure it remains usable when users increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive labels for UI elements.
* **Screen Reader Testing:** Regularly test your app with TalkBack (Android) and VoiceOver (iOS).

## Analysis Options
Strictly follow `flutter_lints`.

```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    always_use_package_imports: true
```