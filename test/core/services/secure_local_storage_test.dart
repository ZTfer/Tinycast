import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/secure_local_storage.dart';

class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> values = {};
  bool failAccess = false;

  @override
  Future<String?> read(String key) async {
    if (failAccess) throw Exception('keychain unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failAccess) throw Exception('keychain unavailable');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failAccess) throw Exception('keychain unavailable');
    values.remove(key);
  }
}

void main() {
  const sessionKey = 'sb-test-auth-token';

  late FakeSecureKeyValueStore store;

  setUp(() {
    store = FakeSecureKeyValueStore();
  });

  SecureLocalStorage buildStorage() =>
      SecureLocalStorage(persistSessionKey: sessionKey, store: store);

  group('SecureLocalStorage', () {
    test('initialize 会把 SharedPreferences 中的旧会话迁移到安全存储', () async {
      SharedPreferences.setMockInitialValues({sessionKey: 'legacy-session'});

      await buildStorage().initialize();

      expect(store.values[sessionKey], equals('legacy-session'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(sessionKey), isFalse);
    });

    test('persistSession 只写入安全存储，不写入 SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final secure = buildStorage();
      await secure.initialize();
      await secure.persistSession('session-json');

      expect(store.values[sessionKey], equals('session-json'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(sessionKey), isFalse);
    });

    test('安全存储不可用时降级为内存会话且不写 SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      store.failAccess = true;

      final secure = buildStorage();
      await secure.initialize();
      await secure.persistSession('memory-session');

      expect(await secure.accessToken(), equals('memory-session'));
      expect(await secure.hasAccessToken(), isTrue);
      expect(store.values, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(sessionKey), isFalse);
    });

    test('removePersistedSession 会删除安全存储中的会话', () async {
      SharedPreferences.setMockInitialValues({});
      store.values[sessionKey] = 'session-json';

      final secure = buildStorage();
      await secure.initialize();
      await secure.removePersistedSession();

      expect(store.values, isEmpty);
      expect(await secure.hasAccessToken(), isFalse);
    });
  });
}
