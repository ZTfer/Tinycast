# 设置模块存储规则

## 概述

TinyCast 的设置分为三类：用户可调设置、同步簿记数据、敏感凭证。三者使用不同的
存储介质，不能混用。

## 存储策略

### 用户设置 —— Isar `AppSettingsModel`

**唯一主存储**：所有用户可调设置都保存在 Isar 的 `AppSettingsModel` 集合中，
固定使用单例 `id = 0`，读写统一经过 `SettingsService`
（`lib/data/services/settings_service.dart`）。

适用范围：

- 播放设置：倍速、音量、快进 / 快退秒数、连续播放；
- 下载设置：收藏时下载、播放完移除下载、自动下载策略；
- Feed 刷新：刷新间隔、蜂窝网络刷新、新剧集通知、后台刷新；
- 睡眠定时器及其结束时间。

使用规范：

```dart
// 读：加载完整设置
final settings = await SettingsService.instance.loadSettings();

// 读：监听变更（多窗口自动同步）
final stream = SettingsService.instance.watchSettings();

// 写：通过具名 setter，内部在 writeTxn 中更新 id=0 的记录
await SettingsService.instance.setDownloadOnFavorite(true);
await SettingsService.instance.setAutoDownloadPolicy(AutoDownloadPolicy.latest3);
```

`AppSettingsModel` 中的枚举（`AutoDownloadPolicyEnum`、`FeedRefreshIntervalEnum`、
`SleepTimerEnum`）与 Domain 层枚举通过 `name` 一一映射；新增枚举值时两边都要加，
否则 `byName` 会抛错。

### 同步簿记 —— shared_preferences

`shared_preferences` **不再承载用户设置**，只用于两类数据：

1. **历史设置迁移**：`SettingsService.migrateFromSharedPreferences()` 在首次启动
   （Isar 中没有设置记录时）读取旧键并写入 Isar，之后不再写回；
2. **云同步簿记**：`last_sync_timestamp_<userId>`、墓碑
   `sync_tombstone_*_<userId>`、`sync_pushed_subscription_ids_<userId>`，
   由 `SyncService` / `SyncTombstoneStore` 维护。

禁止事项：

- 不要把新的用户设置写入 `shared_preferences`；
- 不要把敏感信息（密码、Auth Token、API Key）写入 `shared_preferences`。

主题是例外中的例外：它**不持久化**。应用跟随系统亮暗模式，没有“主题设置”项，
也不要为它新增 `shared_preferences` 键或 Isar 字段。

### 敏感凭证 —— flutter_secure_storage

Supabase 会话（access token + refresh token）通过 `SecureLocalStorage`
（`lib/core/services/secure_local_storage.dart`）写入系统安全存储：

```dart
final secureStorage = SecureLocalStorage(
  persistSessionKey: 'supabase_session',
);
await secureStorage.initialize();
await secureStorage.persistSession(sessionJson);
```

安全保证：

- iOS / macOS：Keychain；
- Android：Keystore 支持的加密存储；
- Linux：依赖系统 keyring，缺少 keyring 时降级为**仅内存**保存，用户重启后需要
  重新登录。

`SecureLocalStorage` 还有两个必须保留的行为：

1. **旧数据迁移**：首次初始化时把旧版本写在 `shared_preferences` 中的会话迁移到
   安全存储，并删除明文副本；
2. **失败降级**：安全存储读写失败时记录 `Logger.error`，会话保留在内存中，
   不把 token 回写到 `shared_preferences`。

## 状态管理集成（Riverpod 3）

设置通过 `AsyncNotifierProvider` 暴露，`SettingsNotifier.build()` 负责迁移旧数据、
订阅 Isar 的 `watchSettings()` 流，并返回当前设置。Isar 写入后，
`watchSettings()` 会自动推送新值，UI 不需要手动刷新。

```dart
// lib/presentation/providers/settings_provider.dart
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  final SettingsService _service = SettingsService.instance;

  @override
  Future<AppSettings> build() async {
    await _service.migrateFromSharedPreferences();
    // 订阅变更，写入 state
    return _service.loadSettings();
  }

  Future<void> updateDownloadOnFavorite(bool value) async {
    await _service.setDownloadOnFavorite(value);
  }
}
```

UI 中读取 `AsyncValue`：

```dart
final settingsAsync = ref.watch(settingsProvider);

settingsAsync.when(
  data: (settings) => Switch(
    value: settings.downloadOnFavorite,
    onChanged: (value) {
      ref.read(settingsProvider.notifier).updateDownloadOnFavorite(value);
    },
  ),
  loading: () => const SizedBox(),
  error: (error, stackTrace) => const Text('设置加载失败'),
);
```

注意：

- 不要在 Widget 中直接 `await SettingsService.loadSettings()`；这会绕开 Provider
  的缓存和跨窗口同步；
- `updateFeedRefreshInterval` / `updateBackgroundRefreshEnabled` 会重启
  `FeedRefreshScheduler`，且只在主窗口生效（`AppWindowContext.isMainWindow`）。

## 自动下载策略

Domain 枚举 `AutoDownloadPolicy` 定义在 `lib/domain/entities/app_settings.dart`，
持久化时映射为 Isar 的 `AutoDownloadPolicyEnum`（同名字符串）。

| 枚举值 | 说明 |
|--------|------|
| `off` | 关闭：订阅新播客时不自动下载 |
| `latest1` | 最新 1 集 |
| `latest2` | 最新 2 集 |
| `latest3` | 最新 3 集（默认） |
| `latest5` | 最新 5 集 |
| `latest10` | 最新 10 集 |
| `past24h` | 过去 24 小时内发布的剧集 |
| `past7d` | 过去 7 天内发布的剧集 |
| `past14d` | 过去 14 天内发布的剧集 |
| `past30d` | 过去 30 天内发布的剧集 |
| `all` | 全部剧集 |

执行时机（`lib/presentation/features/search/podcast_search_provider.dart`）：

- 仅在**新订阅**时触发，已订阅播客不会重复执行；
- `off` 直接跳过；
- `latest*` 策略调用 `downloadPodcastEpisodes`；
- 时间范围策略按剧集并发调用 `downloadEpisodeById`；
- 收藏触发下载由 `downloadOnFavorite` 单独控制，与 `AutoDownloadPolicy` 无关。

自动下载只是把任务放入下载队列（最大并发 3），不会等待全部完成。

## 项目依赖

```yaml
dependencies:
  shared_preferences: ^2.5.5        # 仅旧设置迁移 + 同步簿记
  flutter_secure_storage: ^10.0.0   # Supabase 会话
  flutter_riverpod: ^3.3.1          # 状态管理
```

Isar 使用 `isar_community: ^3.3.2`，设置模型位于
`lib/data/models/app_settings_model.dart`。
