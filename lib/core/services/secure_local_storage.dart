import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/utils/logger.dart';

/// 安全键值存储的最小接口，便于在测试中替换平台实现。
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// 使用系统安全存储（Keychain / Keystore）持久化 Supabase 会话。
///
/// 会话中包含 access token 与 refresh token，属于敏感凭据，不能写入
/// SharedPreferences。当平台安全存储不可用（如 Linux 缺少 keyring）时
/// 降级为仅内存保存：用户仍可登录，但重启后需要重新登录。
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({
    required this.persistSessionKey,
    SecureKeyValueStore? store,
  }) : _store = store ?? const FlutterSecureKeyValueStore();

  final String persistSessionKey;
  final SecureKeyValueStore _store;

  bool _secureStorageAvailable = true;
  String? _memorySession;

  @override
  Future<void> initialize() async {
    try {
      final existing = await _store.read(persistSessionKey);
      if (existing != null && existing.isNotEmpty) {
        _memorySession = existing;
        return;
      }
      await _migrateFromSharedPreferences();
    } catch (e, stackTrace) {
      _secureStorageAvailable = false;
      Logger.error(
        '安全存储不可用，Supabase 会话将仅保存在内存中',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 旧版本把会话写在 SharedPreferences 中，首次启动时迁移并删除明文副本。
  Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final legacySession = prefs.getString(persistSessionKey);
    if (legacySession == null || legacySession.isEmpty) return;

    await _store.write(persistSessionKey, legacySession);
    await prefs.remove(persistSessionKey);
    _memorySession = legacySession;
    Logger.info('已将 Supabase 会话从 SharedPreferences 迁移到安全存储');
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await accessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> accessToken() async {
    if (!_secureStorageAvailable) return _memorySession;

    try {
      final token = await _store.read(persistSessionKey);
      _memorySession = token;
      return token;
    } catch (e, stackTrace) {
      _secureStorageAvailable = false;
      Logger.error(
        '读取安全存储失败，改用内存中的 Supabase 会话',
        error: e,
        stackTrace: stackTrace,
      );
      return _memorySession;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    _memorySession = persistSessionString;
    if (!_secureStorageAvailable) return;

    try {
      await _store.write(persistSessionKey, persistSessionString);
    } catch (e, stackTrace) {
      _secureStorageAvailable = false;
      Logger.error(
        '写入安全存储失败，Supabase 会话仅保存在内存中',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> removePersistedSession() async {
    _memorySession = null;
    if (!_secureStorageAvailable) return;

    try {
      await _store.delete(persistSessionKey);
    } catch (e, stackTrace) {
      Logger.error(
        '删除安全存储中的 Supabase 会话失败',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
