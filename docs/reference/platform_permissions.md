# 平台文件与权限配置说明

TinyCast 的数据库、下载音频和封面图都存放在应用私有目录中，通过
`path_provider` 获取；不需要全局存储权限。但音频播放、网络请求和桌面沙盒仍依赖
各平台的权限与 Entitlements 配置。

本文档记录**当前仓库中的实际配置**，以及扩展文件访问能力时需要补的项。

---

## 1. 数据目录与权限边界

| 数据 | 获取方式 | 位置 |
|------|---------|------|
| Isar 数据库 | `getApplicationDocumentsDirectory()` | 应用文档目录下的 `tinycast.isar` |
| 音频文件 | `getApplicationSupportDirectory()/audio` | 应用支持目录 |
| 封面图片 | `getApplicationSupportDirectory()/images` | 应用支持目录 |
| 下载临时文件 | `getTemporaryDirectory()` | 系统临时目录，完成后删除 |

这些目录都在应用沙盒或私有数据目录内。应用不会请求访问用户相册、下载目录或
任意外部文件，因此当前不需要存储类权限。

各平台的实际根路径：

- **iOS**：应用沙盒内的 `Library/Application Support/` 与 `Documents/`；
- **macOS（沙盒）**：`~/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/`
  与 `.../Data/Documents/`；
- **Android**：`/data/data/com.example.tinycast/` 下的私有目录；
- **Linux**：`~/.local/share/tinycast/`；
- **Windows**：`%APPDATA%` 下的应用目录。

具体路径以启动日志和 `path_provider` 返回值为准，不同打包方式可能略有差异。

---

## 2. iOS

**配置文件**：`ios/Runner/Info.plist`

**当前状态**：不需要文件访问权限。

已配置的相关键：

- `UIBackgroundModes`：`audio`、`fetch`，用于后台音频播放和 Feed 刷新；
- `CFBundleURLTypes`：`io.supabase.tinycast`，用于 Supabase 登录回调。

没有配置 `NSPhotoLibraryUsageDescription`、`NSDocumentsFolderUsageDescription`
等文件访问描述，因为应用只读写自己的沙盒目录。

如果将来加入“从文件 App 导入音频 / OPML”或“保存到照片库”等功能，需要：

1. 使用系统文件选择器（`UIDocumentPickerViewController` / `file_picker`），
   通常不需要额外权限描述；
2. 若要直接访问照片库，添加 `NSPhotoLibraryUsageDescription`；
3. 若要长期访问用户选择的外部目录，保存安全作用域书签（security-scoped bookmark）。

---

## 3. macOS

**配置文件**：

- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

**当前状态**：已启用 App Sandbox，联网权限齐全，不需要文件系统全盘权限。

### DebugProfile.entitlements

| Entitlement | 值 | 用途 |
|-------------|-----|------|
| `com.apple.security.app-sandbox` | `true` | 启用应用沙盒 |
| `com.apple.security.cs.allow-jit` | `true` | Debug 下 Dart VM 的 JIT |
| `com.apple.security.network.client` | `true` | 发起网络请求（RSS、iTunes、Supabase、下载） |
| `com.apple.security.network.server` | `true` | Debug 调试连接（VM Service） |
| `com.apple.security.files.user-selected.read-only` | `true` | 读取用户在文件选择器中选中的文件 |

### Release.entitlements

| Entitlement | 值 | 用途 |
|-------------|-----|------|
| `com.apple.security.app-sandbox` | `true` | 启用应用沙盒 |
| `com.apple.security.network.client` | `true` | 网络请求与下载 |
| `com.apple.security.files.user-selected.read-only` | `true` | 读取用户选择的文件 |

Release **不包含** JIT 和 `network.server`，这是预期配置：发布包不需要 Dart VM
调试能力，也不应开放额外的入站网络监听。

沙盒内 `getApplicationSupportDirectory()` 与 `getApplicationDocumentsDirectory()`
可直接读写，无需额外文件权限。

如果将来需要“导出音频 / OPML 到用户选择的位置”，把
`com.apple.security.files.user-selected.read-only` 改为 `read-write`，并保持
Debug 与 Release 两份文件一致。

---

## 4. Android

**配置文件**：`android/app/src/main/AndroidManifest.xml`

**当前状态**：已声明网络、前台播放服务相关权限；没有存储权限。

当前 `uses-permission`：

- `android.permission.INTERNET`：RSS、iTunes、Supabase 与音频下载；
- `android.permission.WAKE_LOCK`：播放期间保持 CPU 唤醒；
- `android.permission.FOREGROUND_SERVICE`：前台播放服务；
- `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`：Android 14+ 的
  `mediaPlayback` 前台服务类型。

配套声明：

- `com.ryanheise.audioservice.AudioService`：
  `android:foregroundServiceType="mediaPlayback"`；
- `com.ryanheise.audioservice.MediaButtonReceiver`：耳机 / 媒体按键；
- `io.supabase.tinycast://login-callback`：Supabase 登录回调的 deep link。

没有 `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`，因为音频和数据库都写入
应用私有目录（`/data/data/com.example.tinycast/`），不需要这些权限。

如果将来要保存到公共音乐目录或读取外部文件，优先使用 Storage Access Framework
（`ACTION_OPEN_DOCUMENT` / `ACTION_CREATE_DOCUMENT`），而不是申请广泛存储权限；
在 Android 13+ 上，通知还需要 `POST_NOTIFICATIONS` 运行时权限（当前未声明）。

---

## 5. Linux

**打包方式**：当前未使用 Snap / Flatpak。

**当前状态**：不需要额外配置。

- `getApplicationSupportDirectory()` 返回 `~/.local/share/tinycast/`；
- 桌面构件的音频播放使用系统音频服务，网络访问不受额外限制；
- 若将来使用 Snap，需要声明 `home`、`personal-files` 或具体目录的 `removable-media`
  plug；
- 若使用 Flatpak，需要在 manifest 中授予 `--filesystem=home` 或更窄的
  `xdg-data` 访问权限。

---

## 6. Windows

**配置文件**：无需额外配置文件。

**当前状态**：不需要额外配置。

应用数据写入 `%APPDATA%` 下的应用目录，属于当前用户的标准可写位置；
网络下载和音频播放不需要额外权限声明。

---

## 7. 总结

| 平台 | 文件访问权限 | 额外配置 | 当前状态 |
|------|:-----------:|---------|:---------:|
| iOS | 不需要 | 后台音频 / fetch、登录回调 URL Scheme | ✅ 正常 |
| macOS | 不需要（沙盒内） | App Sandbox、网络 client / server、JIT、用户选择文件只读 | ✅ 正常 |
| Android | 不需要 | 网络、前台媒体播放服务 | ✅ 正常 |
| Linux | 不需要 | 无 Snap / Flatpak 封装 | ✅ 正常 |
| Windows | 不需要 | 无 | ✅ 正常 |

## 8. 未来扩展

需要访问沙盒外文件时，按目标平台补充配置：

- **iOS**：文件选择器通常无需权限；照片库需要 `NSPhotoLibraryUsageDescription`；
  长期访问外部目录需要安全作用域书签；
- **macOS**：把用户选择文件权限改为 `read-write`，Debug / Release 同步修改；
- **Android**：优先使用 SAF；确需广泛访问时再评估存储权限与商店审核要求；
- **Linux**：Snap / Flatpak 需要显式声明文件系统访问范围。

修改权限后要同时验证 Debug 与 Release：macOS 的 JIT / `network.server` 只应存在于
DebugProfile，不应为了“让功能跑起来”把它们加进 Release。
