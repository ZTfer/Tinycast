# 平台文件权限配置说明

## 概述

Tinycast 使用 `path_provider` 的 `getApplicationSupportDirectory()` 来存储应用数据，该目录位于应用沙盒内，因此大多数情况下不需要额外的文件访问权限。

## 各平台配置详情

### iOS 平台

**配置文件**: `ios/Runner/Info.plist`

**当前状态**: ✅ 无需额外配置

**说明**:

- iOS 应用使用沙盒机制，`getApplicationSupportDirectory()` 返回应用沙盒内的目录
- 当前 Info.plist 未包含任何文件访问权限配置
- 如果需要访问沙盒外的文件（如照片库、文件选择器），需要添加相应的权限描述

**如需访问沙盒外文件，可能需要添加**:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问照片库以选择文件</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>需要访问文档文件夹以读取文件</string>
```

### macOS 平台

**配置文件**:

- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

**当前状态**: ✅ 无需额外配置

**说明**:

- macOS 应用使用沙盒机制，`getApplicationSupportDirectory()` 返回应用沙盒内的目录
- DebugProfile.entitlements 包含了 JIT 和网络服务器权限（用于开发调试）
- Release.entitlements 仅包含基本的沙盒配置

**当前配置**:

- DebugProfile: `com.apple.security.app-sandbox`,
  `com.apple.security.cs.allow-jit`,
  `com.apple.security.network.server`
- Release: `com.apple.security.app-sandbox`

**如需访问沙盒外文件，可能需要添加**:

```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

### Android 平台

**配置文件**: `android/app/src/main/AndroidManifest.xml`

**当前状态**: ✅ 无需额外配置

**说明**:

- Android 应用使用私有目录，`getApplicationSupportDirectory()` 返回应用私有目录
- 当前 AndroidManifest.xml 未包含任何存储权限
- 应用私有目录（`/data/data/com.example.tinycast/`）无需额外权限即可访问

**如需访问外部存储，可能需要添加**:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Linux 平台

**打包方式**: 未使用 Snap/Flatpak

**当前状态**: ✅ 无需额外配置

**说明**:

- Linux 应用使用标准用户目录，`getApplicationSupportDirectory()` 返回 `~/.local/share/tinycast/`
- 当前未使用 Snap 或 Flatpak 打包，因此无需配置相关的文件访问权限

**如果将来使用 Snap 打包，可能需要添加**:

```yaml
plugs:
  - home
  - personal-files
```

**如果将来使用 Flatpak 打包，可能需要添加**:

```ini
[Context]
filesystems=home;xdg-data
```

### Windows 平台

**配置文件**: 无需配置文件

**当前状态**: ✅ 无需额外配置

**说明**:

- Windows 应用使用 AppData 目录，`getApplicationSupportDirectory()` 返回 `%APPDATA%\tinycast\`
- AppData 目录是应用的标准数据存储位置，无需额外权限
- 当前 Windows 平台配置文件中无需任何特殊权限设置

## 总结

由于 Tinycast 使用 `path_provider` 的 `getApplicationSupportDirectory()` 在应用沙盒内存储数据，所有平台均无需额外的文件访问权限配置。

| 平台 | 需要额外权限 | 当前状态 |
| ------ | :-------------: | :---------: |
| iOS | ❌ 否 | ✅ 正常 |
| macOS | ❌ 否 | ✅ 正常 |
| Android | ❌ 否 | ✅ 正常 |
| Linux | ❌ 否 | ✅ 正常 |
| Windows | ❌ 否 | ✅ 正常 |

## 未来扩展

如果未来需要访问沙盒外的文件（如用户选择的文件、照片库、文档等），需要根据目标平台添加相应的权限配置和 Entitlements。
