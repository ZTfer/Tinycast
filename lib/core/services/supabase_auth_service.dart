import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/utils/logger.dart';

class SupabaseAuthService {
  SupabaseClient get _client => SupabaseService().client;

  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null,
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
