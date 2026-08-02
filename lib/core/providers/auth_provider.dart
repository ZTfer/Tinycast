import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';

final supabaseConfiguredProvider = Provider<bool>((ref) {
  return SupabaseService().isInitialized;
});

final authStateProvider = StreamProvider<User?>((ref) {
  if (!SupabaseService().isInitialized) {
    return Stream<User?>.value(null);
  }
  return SupabaseService().client.auth.onAuthStateChange.asyncMap(
    (event) => event.session?.user,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  if (!SupabaseService().isInitialized) return null;
  return SupabaseService().client.auth.currentUser;
});
