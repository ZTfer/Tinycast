# 依赖升级总结

## 升级内容

### 依赖版本变更

| 依赖包           | 旧版本 | 新版本 |
| ---------------- | ------ | ------ |
| riverpod         | 2.6.1  | 3.2.1  |
| flutter_riverpod | 2.6.1  | 3.3.1  |

### 开发依赖

- `build_runner` 保持 2.7.1（最新版 2.13.0 与 `isar_community_generator` 不兼容）

## 处理的破坏性变更

### Riverpod 3.x 迁移

Riverpod 3.x 移除了 `StateNotifier`，需要迁移到新的 `Notifier` 模式：

1. **base_state_notifier.dart**
   - `BaseStateNotifier` → `BaseNotifier`
   - `BaseListStateNotifier` → `BaseListNotifier`
   - `BasePaginatedStateNotifier` → `BasePaginatedNotifier`
   - `valueOrNull` → `value`

2. **podcast_provider.dart**
   - `StateNotifier<PodcastState>` → `Notifier<PodcastState>`
   - `StateNotifierProvider` → `NotifierProvider`

3. **podcast_search_provider.dart**
   - 同上迁移模式

4. **base_provider.dart**
   - 移除了不再使用的类型和方法（如 `ChangeNotifierProvider`、`ProviderFamily` 等）

## 迁移模式示例

```dart
// 旧代码 (Riverpod 2.x)
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());
  
  void doSomething() {
    state = state.copyWith(...);
  }
}

final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

// 新代码 (Riverpod 3.x)
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState.initial();
  
  void doSomething() {
    state = state.copyWith(...);
  }
}

final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

## 验证结果

- ✅ `flutter pub get` 执行成功
- ✅ `flutter analyze` 无错误或警告
- ✅ 应用成功编译（macOS debug）
- ✅ 删除了无用的默认模板测试文件

## 其他变更

- 删除了 `test/widget_test.dart`（默认的 Flutter 计数器模板测试，与项目无关）
