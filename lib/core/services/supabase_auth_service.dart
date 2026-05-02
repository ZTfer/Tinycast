import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/utils/logger.dart';

class SupabaseAuthService {
  SupabaseClient get _client => SupabaseService().client;

  /// 桌面端 OAuth 回调 URL
  /// 格式：[YOUR_SCHEME]://[YOUR_HOSTNAME]
  /// 需要在 Supabase Dashboard 的 URL Configuration 中注册
  static const _redirectUrl = 'io.supabase.tinycast://login-callback/';

  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } catch (e) {
      Logger.error('Google login failed', error: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      Logger.error('Sign out failed', error: e);
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
