import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Session reactiva: cambia al instante cuando haces login/logout
final sessionProvider = Provider<Session?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return authStateAsync.when(
    data: (state) => state.session,
    loading: () => Supabase.instance.client.auth.currentSession,
    error: (_, __) => Supabase.instance.client.auth.currentSession,
  );
});
