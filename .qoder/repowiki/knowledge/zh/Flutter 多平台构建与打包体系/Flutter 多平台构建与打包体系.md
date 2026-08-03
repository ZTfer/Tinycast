---
kind: build_system
name: Flutter 多平台构建与打包体系
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - run.sh
    - android/build.gradle.kts
    - android/app/build.gradle.kts
    - ios/Podfile
    - linux/CMakeLists.txt
    - windows/CMakeLists.txt
    - analysis_options.yaml
    - devtools_options.yaml
---

## 构建系统与工具链

TinyCast 是一个基于 Flutter 的跨平台播客应用，采用 Flutter 官方推荐的构建体系，覆盖 Android、iOS、Linux、macOS、Windows 和 Web 六个平台。

### 核心构建工具
- **Flutter SDK**：主构建系统，通过 `pubspec.yaml` 管理依赖和版本（当前 SDK 约束为 `^3.9.2`）
- **Gradle (Kotlin DSL)**：Android 平台构建，使用 `build.gradle.kts` 配置编译选项和构建变体
- **CMake**：Linux 和 Windows 平台原生宿主构建，分别通过 `linux/CMakeLists.txt` 和 `windows/CMakeLists.txt` 管理
- **Xcode + CocoaPods**：iOS 和 macOS 平台构建，通过 `Podfile` 管理原生依赖
- **Dart Analyzer**：代码质量检查，通过 `analysis_options.yaml` 集成 `flutter_lints`

### 本地开发流程
项目提供统一的启动脚本 `run.sh`，支持自动检测操作系统并选择对应平台：
- 默认行为：根据 `uname -s` 自动选择 macOS/Linux/Windows 桌面端
- 显式参数：`./run.sh ios` 或 `./run.sh android` 指定移动平台
- 环境变量：从 `.env` 文件加载 Supabase 配置并通过 `--dart-define` 注入
- 设备选择：支持通过 `Android_Device_ID` 等环境变量指定目标设备

### 构建产物管理
- **统一构建目录**：Android Gradle 配置将构建输出重定向到根目录 `build/` 下，避免碎片化
- **平台特定输出**：各平台保持独立的构建目录结构（`android/build/`、`ios/Pods/`、`linux/build/`、`windows/build/`）
- **资源打包**：静态资源通过 `pubspec.yaml` 的 `assets` 字段声明，包含图片、图标和 HOCON 格式的主题配置

### 代码生成与依赖管理
- **Isar 数据库**：通过 `isar_community_generator` 在 `dev_dependencies` 中声明，运行 `build_runner build` 生成类型安全的数据库代码
- **依赖锁定**：使用 `pubspec.lock` 确保依赖版本一致性
- **测试依赖**：独立管理 `flutter_test`、`mockito`、`test` 等测试框架

### 平台构建配置要点
- **Android**：Java/Kotlin 11 兼容性，Debug/Release 构建变体，签名配置暂用 debug key
- **iOS/macOS**：CocoaPods 集成，禁用统计收集以提升构建性能，支持 Debug/Profile/Release 三种模式
- **Linux**：GTK 3 依赖，C++14 标准，支持交叉编译和系统根目录配置
- **Windows**：C++17 标准，Unicode 支持，Visual Studio 集成优化

### 代码质量与分析
- **Lint 规则**：继承 `package:flutter_lints/flutter.yaml`，可针对单文件或全局禁用规则
- **生成文件排除**：`.g.dart` 文件被分析器排除，避免对代码生成器的干扰
- **实验性 API**：允许 Isar 生成的代码使用实验性成员

### 缺失的自动化
仓库中未发现 CI/CD 配置文件（如 `.github/workflows/`、`.gitlab-ci.yml`、`Jenkinsfile` 等），也没有 Dockerfile 或 Makefile 等自动化构建脚本。构建主要依赖开发者本地环境执行 Flutter 命令。