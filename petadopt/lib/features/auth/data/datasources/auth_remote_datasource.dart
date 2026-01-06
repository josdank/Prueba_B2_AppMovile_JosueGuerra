import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/env.dart';
import '../models/profile_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSource(this.client);

  // Signup con redirect a /auth/callback (web auxiliar)
  Future<void> signUpEmail(String email, String password) async {
    await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: '${Env.webAuxUrl}/auth/callback',
    );
  }

  Future<void> signInEmail(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Forgot password -> envía correo a /reset (web auxiliar)
  Future<void> sendPasswordResetEmail(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: '${Env.webAuxUrl}/reset',
    );
  }

  Future<ProfileModel?> getMyProfile() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;

    final data = await client.from('profiles').select().eq('id', uid).maybeSingle();
    if (data == null) return null;

    return ProfileModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> upsertMyProfile(ProfileModel profile) async {
    await client.from('profiles').upsert(profile.toInsertMap());
  }
}
