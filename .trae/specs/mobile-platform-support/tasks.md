# Tasks
- [x] Task 1: 修改 main.dart 添加移动端平台检测和路由
  - [x] 在 main() 函数中添加 Platform.isIOS / Platform.isAndroid 检测
  - [x] 移动端分支：跳过 WindowUtils.initialize() 和 WindowController 相关初始化，直接初始化 IsarService、AudioPlayerService 等核心服务后 runApp 使用 MobileHome
  - [x] 桌面端分支：保持现有的多窗口逻辑不变
  - [x] 创建移动端专用的 MyAppMobile widget，使用 MaterialApp 包裹 MobileHome
- [x] Task 2: 修改 multi_window.dart 使桌面窗口初始化函数移动端安全
  - [x] 在 initMainWindow()、initSettingsWindow()、initSubscribeWindow()、initEpisodeDetailWindow() 函数开头添加平台检查
  - [x] 移动端调用时直接 return，不执行 window_manager 相关代码
  - [x] 在 SettingsWindowApp、SubscribeWindowApp、EpisodeDetailWindowApp 的 WindowControls 使用处已用 Platform.isWindows 保护，无需修改
- [x] Task 3: 更新 window_utils.dart 的条件导出适配移动端
  - [x] 验证当前 window_utils_native.dart 使用 flutter_acrylic（支持 macOS/Windows/Linux），移动端不会被编译到
  - [x] 确认 window_utils_unsupported.dart 的空实现在移动端生效
  - [x] 在 window_utils_native.dart 所有方法中添加 Platform.isIOS/Android 守卫
- [x] Task 4: 更新 MobileHome 页面使其功能完整可用
  - [x] 在 mobile_home.dart 中引入必要的导入（Body 组件、MiniPlayer 等）
  - [x] 创建适合移动端的布局结构（Scaffold + AppBar + Body + MiniPlayer）
  - [x] 确保移动端不包含 WindowControls 等桌面专属组件

# Task Dependencies
- [Task 2] 依赖于 [Task 1] 完成（因为 main.dart 会调用 multi_window.dart 的函数）
- [Task 3] 可与 [Task 1] 并行（独立修改 window_utils 导出）
- [Task 4] 可与 [Task 1] 并行（MobileHome 独立开发）
