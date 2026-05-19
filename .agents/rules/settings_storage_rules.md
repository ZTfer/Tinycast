# 设置模块存储规则

## 概述

本规则定义 TinyCast 播客应用中设置模块的存储策略、状态管理集成以及最佳实践。

## 存储策略

### 普通设置 - shared_preferences

**适用范围**：
- 主题设置（深色/浅色模式）
- 播放设置（倍速、跳转时间、连续播放）
- 下载设置（收藏时下载、播放完自动删除、自动下载策略）
- 通用开关和枚举值
- 复杂设置组（通过 JSON 序列化存储）

**使用规范**：
```dart
// 1. 基础类型直接存储
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('downloadOnFavorite', value);
await prefs.setString('autoDownloadPolicy', policy.name);

// 2. 复杂设置组转 JSON 存储
final settings = DownloadSettings(...);
await prefs.setString('downloadSettings', jsonEncode(settings.toJson()));
```

**禁止事项**：
- 不要使用 shared_preferences 存储敏感信息（如用户密码、Auth Token）

### 敏感信息 - flutter_secure_storage

**适用范围**：
- Auth Token
- 用户密码
- API Keys
- 其他敏感凭证

**使用规范**：
```dart
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'auth_token', value: token);
final token = await secureStorage.read(key: 'auth_token');
```

**安全保证**：
- iOS: 数据存储于 Keychain
- Android: 数据存储于 Keystore

## 状态管理集成 (Riverpod)

### 为什么需要状态管理

为了让 UI 能够**实时响应**设置的变化（比如切换了深色模式，界面立马变黑），必须将设置项放入状态管理中。

### 实现模式

```dart
// 1. 定义 Notifier
class SettingsNotifier extends Notifier<AppSettings> {
  final SettingsService _service = SettingsService();

  @override
  AppSettings build() {
    // 初始化时加载设置
    return _service.loadSettings();
  }

  // 2. 提供修改设置的方法
  Future<void> updateDownloadOnFavorite(bool value) async {
    await _service.saveDownloadOnFavorite(value);
    state = state.copyWith(downloadOnFavorite: value);
  }
}

// 3. 定义 Provider
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
```

### UI 中使用

```dart
// 监听设置变化，UI 自动更新
Consumer(
  builder: (context, ref, child) {
    final settings = ref.watch(settingsProvider);
    return Switch(
      value: settings.downloadOnFavorite,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).updateDownloadOnFavorite(value);
      },
    );
  },
)
```

## 自动下载策略

### AutoDownloadPolicy 枚举

| 枚举值 | 说明 |
|--------|------|
| `off` | 关闭：订阅新播客时，不自动下载音频文件 |
| `latest1` | 最新 1 集：自动下载最新1集 |
| `latest2` | 最新 2 集：自动下载最新2集 |
| `latest3` | 最新 3 集（默认）：自动下载最新3集 |
| `latest5` | 最新 5 集：自动下载最新5集 |
| `latest10` | 最新 10 集：自动下载最新10集 |
| `past24h` | 过去 24 小时：下载过去24小时内的所有episode |
| `past7d` | 过去 7 天：下载过去7天内的所有episode |
| `past14d` | 过去 14 天：下载过去14天内的所有episode |
| `past30d` | 过去 30 天：下载过去30天内的所有episode |
| `all` | 所有单集：下载所有episode |

### 订阅时执行逻辑

```dart
Future<void> onSubscribe(Podcast podcast, AutoDownloadPolicy policy) async {
  if (policy == AutoDownloadPolicy.off) return;
  
  final episodes = await fetchEpisodes(podcast);
  final toDownload = switch (policy) {
    AutoDownloadPolicy.latest1 => episodes.take(1),
    AutoDownloadPolicy.latest3 => episodes.take(3),
    AutoDownloadPolicy.past7d => episodes.where((e) => e.pubDate.isAfter(DateTime.now().subtract(Duration(days: 7)))),
    AutoDownloadPolicy.all => episodes,
    // ... 其他策略
  };
  
  for (final episode in toDownload) {
    await downloadService.download(episode);
  }
}
```

## 项目依赖

```yaml
dependencies:
  shared_preferences: ^2.5.5
  flutter_secure_storage: ^9.2.2
  flutter_riverpod: ^3.3.1
  riverpod: ^3.2.1
```
