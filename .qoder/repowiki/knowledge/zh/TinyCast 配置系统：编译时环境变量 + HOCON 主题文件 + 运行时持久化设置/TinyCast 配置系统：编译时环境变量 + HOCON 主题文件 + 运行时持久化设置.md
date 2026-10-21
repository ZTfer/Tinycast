---
kind: configuration_system
name: TinyCast 配置系统：编译时环境变量 + HOCON 主题文件 + 运行时持久化设置
category: configuration_system
scope:
    - '**'
source_files:
    - lib/main.dart
    - .env.example
    - assets/themes/colors.conf
    - assets/themes/typography.conf
    - assets/themes/styles.conf
    - lib/core/theme/theme_loader.dart
    - lib/core/theme/app_theme_config.dart
    - lib/core/theme/theme_source_flag.dart
    - lib/data/services/settings_service.dart
    - lib/core/services/supabase_service.dart
    - pubspec.yaml
---

## 1. 使用的系统与工具
- **编译时环境变量**：通过 `String.fromEnvironment`（`--dart-define`）注入 Supabase 等敏感配置，不依赖第三方 dotenv 库。
- **HOCON 配置文件**：自定义轻量级 HOCON 解析器，使用 `.conf` 文件管理颜色、排版与样式主题，支持 `include`、`${}` 引用与注释。
- **运行时持久化**：用户设置通过 Isar 数据库持久化，首次启动从 `shared_preferences` 迁移；敏感信息（如 Session）由 `flutter_secure_storage` 管理。
- **平台构建配置**：Android/iOS/Linux/macOS/Windows 各自保留原生工程配置文件（Gradle、Xcode、CMake 等），Flutter 层统一由 `pubspec.yaml` 声明资源与依赖。

## 2. 核心文件与包
- **应用入口与编译期配置**
  - `lib/main.dart`：定义 `AppConfig`，通过 `String.fromEnvironment('SUPABASE_URL'/'SUPABASE_ANON_KEY')` 读取，提供 `isPlaceholder` 判断是否跳过 Supabase 初始化。
  - `.env.example`：Supabase URL 与匿名 Key 的模板，明确标注不要提交到版本控制。
- **主题与样式配置（HOCON）**
  - `assets/themes/colors.conf`：颜色调色板（brand/background/gray/label/overlay），区分 light/dark。
  - `assets/themes/typography.conf`：文本样式（h1-h3/body/caption/button），按 desktop/tablet/mobile 维度组织。
  - `assets/themes/styles.conf`：聚合 colors 与 typography，定义 widgets/page/window_container/multi_window 等 UI 样式，使用 `${...}` 引用其他配置项。
- **HOCON 解析与加载**
  - `lib/core/theme/theme_loader.dart`：内置 `HoconParser` 实现 tokenize → parseObject → include 合并 → `${}` 引用解析 → 缓存；`ThemeLoader` 提供 `preloadThemeConfigs()`、`loadColors()`、`loadTypography()`、`loadStyles()` 等方法。
  - `lib/core/theme/app_theme_config.dart`：将 HOCON JSON 映射为强类型 `AppThemeConfig`，支持 `fromJsonWithMode(isDark)`。
  - `lib/core/theme/theme_source_flag.dart`：`ThemeSource.useHardcoded = false` 控制优先使用 .conf 文件还是硬编码常量。
- **运行时设置持久化**
  - `lib/data/services/settings_service.dart`：以单例形式读写 Isar 中的 `AppSettingsModel`，暴露 `watchSettings()` Stream 实现多窗口同步；提供 `migrateFromSharedPreferences()` 完成旧数据迁移。
  - `lib/core/services/sync_service.dart`：同样使用 `shared_preferences` 做简单键值存储。
  - `lib/core/services/supabase_service.dart`：封装 Supabase 客户端初始化与获取，配合 `main.dart` 中 `AppConfig.isPlaceholder` 决定是否初始化。
- **Flutter 资源声明**
  - `pubspec.yaml`：在 `flutter.assets` 中注册 `assets/themes/*.conf`，使 HOCON 文件可被 `rootBundle.loadString` 读取。

## 3. 架构与设计决策
- **分层清晰**：编译期配置（`AppConfig`）→ 主题配置（HOCON 文件 + ThemeLoader）→ 运行时设置（Isar + SettingsService）三层分离，互不耦合。
- **主题在启动时加载**：默认关闭硬编码模式（`ThemeSource.useHardcoded = false`），HOCON 在启动时预加载进静态缓存；修改 `.conf` 后需重新构建/重启应用，运行期不监听文件。
- **配置引用与复用**：`styles.conf` 通过 `include "colors.conf"` 和 `include "typography.conf"` 组合，使用 `${textstyles.h3.desktop.fontsize}` 等路径引用，避免重复定义。
- **安全策略**：Supabase 凭据通过 `--dart-define` 注入，代码中仅保留占位符；`.env.example` 明确禁止提交真实密钥。
- **向后兼容**：`SettingsService.migrateFromSharedPreferences()` 保证从旧版 `shared_preferences` 平滑迁移到 Isar，失败时记录日志但不中断启动。
- **多窗口共享**：通过 Isar 的 `watch()` 流实现多窗口间设置实时同步，无需额外 IPC。

## 4. 约定与约束
- **编译期配置必须通过 `--dart-define` 传入**：`main.dart` 注释明确要求“不要硬编码真实凭据”，运行命令示例为 `flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx`。
- **`.env` 文件不得提交到版本控制**：`.env.example` 顶部注释明确说明。
- **主题文件必须遵循 HOCON 语法**：支持 `#` 和 `//` 注释、嵌套对象、`include` 指令、`${path.to.value}` 引用；`theme_loader.dart` 中的 `HoconParser` 是实际解析器，新增字段需确保解析逻辑覆盖。
- **颜色值必须为 8 位或 6 位十六进制字符串**：`app_theme_config.dart` 的 `parseColor` 方法要求 `#AARRGGBB` 或 `#RRGGBB` 格式。
- **设置字段命名采用 snake_case**：迁移代码中 `download_on_favorite`、`remove_played_downloads` 等键名固定，新增设置需在迁移逻辑中补充对应读取。
- **主题源切换开关位于 `ThemeSource.useHardcoded`**：修改该常量可在开发/生产环境之间切换配置来源，但需注意硬编码模式会绕过 HOCON 解析流程。
- **所有主题资源必须在 `pubspec.yaml` 中声明**：未注册的 `.conf` 文件无法通过 `rootBundle` 加载，会导致 `ThemeLoader.preloadThemeConfigs()` 抛出异常。