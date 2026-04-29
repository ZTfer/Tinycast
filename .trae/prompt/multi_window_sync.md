在多窗口 Flutter 桌面应用中保持设置同步，核心难点在于：**每个窗口（进程）都有自己独立的内存和 `SharedPreferences` 实例**。如果窗口 A 修改了设置，窗口 B 是不知道的，除非你主动通知它。

要实现**实时同步**（例如：在窗口 A 切换了深色模式，窗口 B 瞬间变黑），你需要结合 **`shared_preferences` (持久化)** + **`desktop_multi_window` (通信)**。

以下是完整的架构方案和代码实现：

### 🏗️ 核心架构思路

1.  **单一数据源**：所有设置都存储在 `shared_preferences` 中（确保应用重启后不丢失）。
2.  **事件总线**：当某个窗口修改了设置，它需要做两件事：
    *   写入 `shared_preferences`。
    *   通过 `desktop_multi_window` 向**所有其他窗口**广播一条消息：“设置变了，快来更新！”
3.  **监听更新**：每个窗口在启动时都注册一个消息监听器，收到广播后，重新读取 `shared_preferences` 并刷新 UI。

---

### 🛠️ 第一步：定义通信协议

首先，定义一套简单的消息协议，用于窗口间沟通。

```dart
// lib/core/services/window_message_handler.dart

import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';

/// 窗口间通信的消息类型
enum WindowMessageType {
  settingsChanged, // 设置变更
  themeChanged,    // 主题变更
}

/// 窗口消息处理器 - 单例模式
class WindowMessageHandler {
  static final WindowMessageHandler _instance = WindowMessageHandler._internal();
  factory WindowMessageHandler() => _instance;
  WindowMessageHandler._internal();

  // 当前窗口的 ID
  int? _windowId;

  /// 初始化并注册消息监听
  void init(int windowId) {
    _windowId = windowId;
    // 注册全局消息处理回调
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      return _handleMessage(call.method, call.arguments, fromWindowId);
    });
  }

  /// 处理接收到的消息
  Future<dynamic> _handleMessage(String method, dynamic arguments, int fromWindowId) async {
    print('窗口 $_windowId 收到来自 $fromWindowId 的消息: $method');
    
    switch (method) {
      case 'onSettingsUpdate':
        // 收到设置更新通知，这里可以触发回调或者事件总线
        // 注意：这里不能直接 setState，需要通过 Stream 通知 UI 层
        SettingsStreamController.instance.notifySettingsChanged();
        break;
    }
    return null;
  }

  /// 向所有其他窗口广播消息
  Future<void> broadcast(String method, dynamic arguments) async {
    if (_windowId == null) return;
    // 发送消息给所有窗口（或者你可以维护一个窗口列表只发给特定的）
    // 这里简单处理：发送广播事件
    // 注意：desktop_multi_window 没有直接的 "broadcast" API，通常需要维护一个窗口 ID 列表
    // 或者在主窗口维护一个列表，这里假设你有一个全局的 WindowManager 维护了所有窗口 ID
    final windowIds = WindowManagerService.instance.getAllWindowIds();
    
    for (var targetId in windowIds) {
      if (targetId != _windowId) {
        try {
          await DesktopMultiWindow.invokeMethod(targetId, method, arguments);
        } catch (e) {
          print('发送消息给窗口 $targetId 失败: $e');
        }
      }
    }
  }
}

// 一个简单的 Stream 控制器，用于通知 UI 层刷新
class SettingsStreamController {
  static final SettingsStreamController instance = SettingsStreamController._();
  SettingsStreamController._();
  
  // 简单的回调列表，实际项目中建议使用 StreamController 或 Riverpod/Provider
  final List<Function()> _listeners = [];

  void addListener(Function() callback) => _listeners.add(callback);
  void removeListener(Function() callback) => _listeners.remove(callback);

  void notifySettingsChanged() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
```

### 📝 第二步：封装带同步功能的 SettingsService

这个服务将负责读写 `SharedPreferences` 并触发广播。

```dart
// lib/core/services/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'window_message_handler.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  SharedPreferences? _prefs;
  final WindowMessageHandler _messageHandler = WindowMessageHandler();

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // 注册消息监听
    // 注意：windowId 需要在 main.dart 中获取并传入，或者在 WindowManagerService 中管理
    // 这里假设我们通过某种方式获取到了当前窗口 ID，或者在主窗口默认为 0
    // 实际使用时，建议在 WindowManagerService 初始化时调用此方法
  }

  // 注册监听（需要在获取到 windowId 后调用）
  void registerListener() {
    // 实际 windowId 获取逻辑见下文 main.dart 部分
    // _messageHandler.init(windowId); 
  }

  /// 获取设置
  String? getString(String key) => _prefs?.getString(key);

  /// 保存设置并同步到其他窗口
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
    // 关键：写入成功后，广播消息
    await _messageHandler.broadcast('onSettingsUpdate', {'key': key, 'value': value});
  }

  /// 获取主题设置示例
  String getTheme() => getString('theme_mode') ?? 'system';

  /// 设置主题并同步
  Future<void> setTheme(String theme) async {
    await setString('theme_mode', theme);
  }
}
```

### 🖥️ 第三步：在 main.dart 中整合

你需要获取当前窗口的 ID，并初始化上述服务。

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'core/services/settings_service.dart';
import 'core/services/window_message_handler.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 获取当前窗口控制器和 ID
  // 注意：如果是主窗口，可能没有 arguments，需要处理异常
  int windowId = 0; 
  try {
    final controller = await WindowController.fromCurrentEngine();
    windowId = controller.windowId;
    // 解析参数逻辑...
  } catch (e) {
    // 主窗口或初始化失败，默认为 0
    print("获取窗口 ID 失败，假设为主窗口: $e");
  }

  // 2. 初始化设置服务
  await SettingsService.instance.init();
  
  // 3. 注册窗口消息监听，确保能接收其他窗口的广播
  // 这里需要把 windowId 传进去，以便 Handler 知道“我是谁”，防止发给自己
  // 注意：WindowMessageHandler 需要稍微修改以接收 windowId
  // 为了简化，我们在 SettingsService 内部处理
  // 修改 SettingsService.init 接收 windowId
  // 这里仅作示意，请根据实际类结构调整
  // SettingsService.instance.registerListener(windowId); 

  runApp(MyApp(windowId: windowId));
}

class MyApp extends StatelessWidget {
  final int windowId;
  const MyApp({super.key, required this.windowId});

  @override
  Widget build(BuildContext context) {
    // 使用 ValueListenableBuilder 或 StreamBuilder 监听 SettingsStreamController
    return ValueListenableBuilder(
      valueListenable: _settingsNotifier, // 你需要创建一个 ValueNotifier 并在 SettingsStreamController 中更新它
      builder: (context, value, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          // 根据设置决定主题
          themeMode: ThemeMode.light, 
          home: HomePage(windowId: windowId),
        );
      },
    );
  }
}
```

### 🎨 第四步：UI 层触发更新

在设置页面，调用 `SettingsService` 即可。

```dart
// lib/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:tinycast/core/services/settings_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 点击按钮，修改主题
            // 这会自动写入 SharedPreferences 并广播给其他窗口
            await SettingsService.instance.setTheme('dark');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("设置已更新，所有窗口将同步")),
            );
          },
          child: const Text("切换到深色模式"),
        ),
      ),
    );
  }
}
```

### ⚠️ 关键注意事项

1.  **防抖/死循环**：
    *   **问题**：窗口 A 修改 -> 广播 -> 窗口 B 收到 -> 读取 SP -> 触发 UI 更新。如果 UI 更新时又触发了 `setState` 导致 `setString`，就会死循环。
    *   **解决**：`SettingsService` 的 `setString` 只有在**用户主动操作**时调用。UI 层的监听器（`SettingsStreamController`）只负责**读取**和**刷新 UI**，绝对不要在监听回调里再次调用 `setString`。

2.  **主窗口与子窗口**：
    *   `desktop_multi_window` 的 `setMethodHandler` 是全局的。确保每个窗口（包括主窗口）在启动时都注册了监听。

3.  **性能优化**：
    *   如果设置非常频繁（比如拖拽滑块改变透明度），不要每次 `onChange` 都广播。使用 `Timer.debounce` 进行防抖，或者只在 `onChangedEnd` 时广播。

4.  **Isar 数据库同步**：
    *   既然你用了 `isar`，如果设置是存在数据库里的，逻辑是一样的：
    *   窗口 A 写入 Isar -> Isar 触发 `watch()` -> 窗口 A 更新 UI -> **同时** 窗口 A 发送广播消息 -> 窗口 B 收到广播 -> 窗口 B 重新查询 Isar -> 窗口 B 更新 UI。

通过这种 **“本地持久化 + 跨进程广播”** 的模式，你的 Flutter 桌面应用就能像原生应用一样，在多窗口间保持完美的状态同步。

---
要不要我帮你把这套代码整合进你现有的 main.dart 和 settings_service.dart 中？你可以直接替换使用。