# Checklist

## Task 1: main.dart 移动端平台检测
- [x] main() 函数包含 Platform.isIOS / Platform.isAndroid 判断
- [x] 移动端分支跳过 WindowUtils.initialize() 调用
- [x] 移动端分支跳过 WindowController.fromCurrentEngine() 调用
- [x] 移动端分支使用 MobileHome 作为首页组件
- [x] 桌面端分支保持原有逻辑不变
- [x] 移动端使用 MaterialApp 或 WidgetsApp 正确包裹 MobileHome
- [x] 核心服务（IsarService、AudioPlayerService）在移动端正确初始化

## Task 2: multi_window.dart 桌面函数移动端安全
- [x] initMainWindow() 在移动端直接 return
- [x] initSettingsWindow() 在移动端直接 return
- [x] initSubscribeWindow() 在移动端直接 return
- [x] initEpisodeDetailWindow() 在移动端直接 return
- [x] 桌面端函数在桌面平台行为不变

## Task 3: window_utils.dart 条件导出
- [x] window_utils.dart 使用条件导出（桌面端用 native，移动端用 unsupported）
- [x] window_utils_native.dart 不在移动端被编译导入
- [x] window_utils_unsupported.dart 在移动端正确生效
- [x] WindowUtils 类在所有平台都有可用的空实现或真实实现
- [x] TitlebarSafeAreaWrapper 在所有平台都能正常编译

## Task 4: MobileHome 页面功能完整
- [x] mobile_home.dart 正确导入所需依赖
- [x] 使用 Scaffold 作为根组件
- [x] 包含 AppBar 提供导航栏
- [x] Body 组件正确集成显示主要内容
- [x] 不包含 WindowControls 等桌面专属组件
- [x] MiniPlayer 组件正确集成
- [x] 移动端布局响应式，适配不同屏幕尺寸

## 编译验证
- [x] `flutter analyze` 无错误（No issues found!）
