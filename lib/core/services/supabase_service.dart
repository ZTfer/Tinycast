import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/secure_local_storage.dart';

/// Supabase 客户端服务
///
/// 负责初始化和管理 Supabase 连接。
/// 使用 Flutter Secure Storage 管理 Session，支持持久化登录状态。
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  /// 初始化 Supabase 客户端
  ///
  /// 必须在应用启动时调用，通常在 main() 中。
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) {
      return;
    }

    final projectRef = Uri.parse(supabaseUrl).host.split('.').first;

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureLocalStorage(
          persistSessionKey: 'sb-$projectRef-auth-token',
        ),
      ),
    );

    _isInitialized = true;
  }

  /// 获取 Supabase 客户端实例
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService().initialize() first.',
      );
    }
    return Supabase.instance.client;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
}

/// Supabase 客户端 Provider
///
/// 用于在 Riverpod 中访问 Supabase 客户端。
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService().client;
});
