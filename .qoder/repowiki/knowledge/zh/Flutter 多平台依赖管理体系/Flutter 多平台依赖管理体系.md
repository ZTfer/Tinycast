---
kind: dependency_management
name: Flutter 多平台依赖管理体系
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - android/build.gradle.kts
    - android/app/build.gradle.kts
    - ios/Podfile
    - ios/Podfile.lock
    - macos/Podfile
    - android/gradle.properties
    - analysis_options.yaml
---

TinyCast 项目采用 Flutter 标准的多层依赖管理策略，通过 Dart/Flutter、Android Gradle、iOS/macOS CocoaPods 三个层次分别管理各平台的第三方库。

## 核心系统与工具
- **Dart/Flutter 依赖**：使用 `pubspec.yaml` 声明依赖，`pubspec.lock` 锁定具体版本，通过 `flutter pub get` 获取依赖
- **Android 依赖**：Gradle Kotlin DSL (`build.gradle.kts`) 管理 Android 原生依赖，仓库源为 Google 和 Maven Central
- **iOS/macOS 依赖**：CocoaPods (`Podfile` + `Podfile.lock`) 管理原生依赖，禁用统计以提升构建性能

## 关键文件与配置
- `pubspec.yaml`：集中声明所有 Dart 包依赖，按功能模块分组（UI、音频、网络、数据库等），使用语义化版本约束（如 `^3.2.1`）
- `pubspec.lock`：精确锁定所有直接和传递依赖的版本及 SHA256 校验和，确保构建可重现性
- `android/build.gradle.kts`：定义全局仓库源（google()、mavenCentral()）
- `ios/Podfile` 和 `macos/Podfile`：通过 `flutter_install_all_ios_pods` / `flutter_install_all_macos_pods` 自动安装 Flutter 插件对应的原生依赖
- `analysis_options.yaml`：通过 `flutter_lints` 统一代码质量规则

## 架构与约定
- **分层组织**：依赖按功能域分组注释（国际化、UI图标、文件选择、数据库、状态管理、音频播放、网络请求等），便于维护和理解
- **版本策略**：生产依赖使用 `^` 语义化版本约束，允许小版本更新；SDK 版本严格约束（`sdk: ^3.9.2`）
- **开发依赖分离**：测试、代码生成、lint 工具集中在 `dev_dependencies` 中，不进入生产构建
- **平台特定依赖**：桌面端窗口管理（`window_manager`、`desktop_multi_window`）、JNI 调用（`jni`、`jni_flutter`）等按需引入
- **私有仓库**：未发现私有仓库配置，所有依赖均来自官方 pub.dev、Google、Maven Central 等公共源

## 约束与规范
- **锁文件提交**：`pubspec.lock` 已提交到版本控制，确保团队构建一致性
- **构建优化**：Android Gradle 配置了较大的 JVM 内存（8G heap），启用 Gradle daemon 提升构建速度
- **CocoaPods 优化**：设置 `COCOAPODS_DISABLE_STATS=true` 禁用网络统计以减少构建延迟
- **代码生成**：Isar 数据库通过 `isar_community_generator` 在构建时生成类型安全的代码
- **分析器配置**：排除 `.g.dart` 生成文件，忽略 Isar 生成的实验性 API 警告