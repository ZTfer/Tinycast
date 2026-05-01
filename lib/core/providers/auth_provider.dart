import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseService().client.auth.onAuthStateChange.asyncMap(
    (event) => event.session?.user,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService().client.auth.currentUser;
});
